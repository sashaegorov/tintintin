require 'sqlite3'
begin
  SQLite3::Database.instance_method(:type_translation)
rescue
  raise(Sequel::Error, "SQLite3::Database#type_translation is not defined.  If you are using the sqlite3 gem, please install the sqlite3-ruby gem.")
end
Sequel.require 'adapters/shared/sqlite'

module Sequel
  # Top level module for holding all SQLite-related modules and classes
  # for Sequel.
  module SQLite
    TYPE_TRANSLATOR = tt = Class.new do
      FALSE_VALUES = %w'0 false f no n'.freeze
      def boolean(s) !FALSE_VALUES.include?(s.downcase) end
      def integer(s) s.to_i end
      def float(s) s.to_f end
      def numeric(s) ::BigDecimal.new(s) rescue s end
    end.new

    # Hash with string keys and callable values for converting SQLite types.
    SQLITE_TYPES = {}
    {
      %w'date' => ::Sequel.method(:string_to_date),
      %w'time' => ::Sequel.method(:string_to_time),
      %w'bit bool boolean' => tt.method(:boolean),
      %w'integer smallint mediumint int bigint' => tt.method(:integer),
      %w'numeric decimal money' => tt.method(:numeric),
      %w'float double real dec fixed' + ['double precision'] => tt.method(:float),
      %w'blob' => ::Sequel::SQL::Blob.method(:new)
    }.each do |k,v|
      k.each{|n| SQLITE_TYPES[n] = v}
    end
    
    # Database class for SQLite databases used with Sequel and the
    # ruby-sqlite3 driver.
    class Database < Sequel::Database
      include ::Sequel::SQLite::DatabaseMethods
      
      set_adapter_scheme :sqlite
      
      # Mimic the file:// uri, by having 2 preceding slashes specify a relative
      # path, and 3 preceding slashes specify an absolute path.
      def self.uri_to_options(uri) # :nodoc:
        { :database => (uri.host.nil? && uri.path == '/') ? nil : "#{uri.host}#{uri.path}" }
      end
      
      private_class_method :uri_to_options

      # The conversion procs to use for this database
      attr_reader :conversion_procs

      def initialize(opts={})
        super
        @conversion_procs = SQLITE_TYPES.dup
        @conversion_procs['timestamp'] = method(:to_application_timestamp)
        @conversion_procs['datetime'] = method(:to_application_timestamp)
      end
      
      # Connect to the database.  Since SQLite is a file based database,
      # the only options available are :database (to specify the database
      # name), and :timeout, to specify how long to wait for the database to
      # be available if it is locked, given in milliseconds (default is 5000).
      def connect(server)
        opts = server_opts(server)
        opts[:database] = ':memory:' if blank_object?(opts[:database])
        db = ::SQLite3::Database.new(opts[:database])
        db.busy_timeout(opts.fetch(:timeout, 5000))
        
        connection_pragmas.each{|s| log_yield(s){db.execute_batch(s)}}
        
        class << db
          attr_reader :prepared_statements
        end
        db.instance_variable_set(:@prepared_statements, {})
        
        db
      end
      
      # Run the given SQL with the given arguments and yield each row.
      def execute(sql, opts={}, &block)
        _execute(:select, sql, opts, &block)
      end

      # Run the given SQL with the given arguments and return the number of changed rows.
      def execute_dui(sql, opts={})
        _execute(:update, sql, opts)
      end
      
      # Drop any prepared statements on the connection when executing DDL.  This is because
      # prepared statements lock the table in such a way that you can't drop or alter the
      # table while a prepared statement that references it still exists.
      def execute_ddl(sql, opts={})
        synchronize(opts[:server]) do |conn|
          conn.prepared_statements.values.each{|cps, s| cps.close}
          conn.prepared_statements.clear
          super
        end
      end
      
      # Run the given SQL with the given arguments and return the last inserted row id.
      def execute_insert(sql, opts={})
        _execute(:insert, sql, opts)
      end
      
      # Run the given SQL with the given arguments and return the first value of the first row.
      def single_value(sql, opts={})
        _execute(:single_value, sql, opts)
      end
      
      private
      
      # Yield an available connection.  Rescue
      # any SQLite3::Exceptions and turn them into DatabaseErrors.
      def _execute(type, sql, opts, &block)
        begin
          synchronize(opts[:server]) do |conn|
            return execute_prepared_statement(conn, type, sql, opts, &block) if sql.is_a?(Symbol)
            log_args = opts[:arguments]
            args = {}
            opts.fetch(:arguments, {}).each{|k, v| args[k] = prepared_statement_argument(v)}
            case type
            when :select
              log_yield(sql, log_args){conn.query(sql, args, &block)}
            when :single_value
              log_yield(sql, log_args){conn.get_first_value(sql, args)}
            when :insert
              log_yield(sql, log_args){conn.execute(sql, args)}
              conn.last_insert_row_id
            when :update
              log_yield(sql, log_args){conn.execute_batch(sql, args)}
              conn.changes
            end
          end
        rescue SQLite3::Exception => e
          raise_error(e)
        end
      end
      
      # The SQLite adapter does not need the pool to convert exceptions.
      # Also, force the max connections to 1 if a memory database is being
      # used, as otherwise each connection gets a separate database.
      def connection_pool_default_options
        o = super.dup
        # Default to only a single connection if a memory database is used,
        # because otherwise each connection will get a separate database
        o[:max_connections] = 1 if @opts[:database] == ':memory:' || blank_object?(@opts[:database])
        o
      end
      
      def prepared_statement_argument(arg)
        case arg
        when Date, DateTime, Time, TrueClass, FalseClass
          literal(arg)[1...-1]
        when SQL::Blob
          arg.to_blob
        else
          arg
        end
      end

      # Execute a prepared statement on the database using the given name.
      def execute_prepared_statement(conn, type, name, opts, &block)
        ps = prepared_statements[name]
        sql = ps.prepared_sql
        args = opts[:arguments]
        ps_args = {}
        args.each{|k, v| ps_args[k] = prepared_statement_argument(v)}
        if cpsa = conn.prepared_statements[name]
          cps, cps_sql = cpsa
          if cps_sql != sql
            cps.close
            cps = nil
          end
        end
        unless cps
          cps = log_yield("Preparing #{name}: #{sql}"){conn.prepare(sql)}
          conn.prepared_statements[name] = [cps, sql]
        end
        if block
          log_yield("Executing prepared statement #{name}", args){cps.execute(ps_args, &block)}
        else
          log_yield("Executing prepared statement #{name}", args){cps.execute!(ps_args){|r|}}
          case type
          when :insert
            conn.last_insert_row_id
          when :update
            conn.changes
          end
        end
      end
      
      # The main error class that SQLite3 raises
      def database_error_classes
        [SQLite3::Exception]
      end

      # Disconnect given connections from the database.
      def disconnect_connection(c)
        c.prepared_statements.each_value{|v| v.first.close}
        c.close
      end
    end
    
    # Dataset class for SQLite datasets that use the ruby-sqlite3 driver.
    class Dataset < Sequel::Dataset
      include ::Sequel::SQLite::DatasetMethods

      Database::DatasetClass = self
      
      PREPARED_ARG_PLACEHOLDER = ':'.freeze
      
      # SQLite already supports named bind arguments, so use directly.
      module ArgumentMapper
        include Sequel::Dataset::ArgumentMapper
        
        protected
        
        # Return a hash with the same values as the given hash,
        # but with the keys converted to strings.
        def map_to_prepared_args(hash)
          args = {}
          hash.each{|k,v| args[k.to_s.gsub('.', '__')] = v}
          args
        end
        
        private
        
        # SQLite uses a : before the name of the argument for named
        # arguments.
        def prepared_arg(k)
          LiteralString.new("#{prepared_arg_placeholder}#{k.to_s.gsub('.', '__')}")
        end

        # Always assume a prepared argument.
        def prepared_arg?(k)
          true
        end
      end
      
      # SQLite prepared statement uses a new prepared statement each time
      # it is called, but it does use the bind arguments.
      module BindArgumentMethods
        include ArgumentMapper
        
        private
        
        # Run execute_select on the database with the given SQL and the stored
        # bind arguments.
        def execute(sql, opts={}, &block)
          super(sql, {:arguments=>bind_arguments}.merge(opts), &block)
        end
        
        # Same as execute, explicit due to intricacies of alias and super.
        def execute_dui(sql, opts={}, &block)
          super(sql, {:arguments=>bind_arguments}.merge(opts), &block)
        end
        
        # Same as execute, explicit due to intricacies of alias and super.
        def execute_insert(sql, opts={}, &block)
          super(sql, {:arguments=>bind_arguments}.merge(opts), &block)
        end
      end

      module PreparedStatementMethods
        include BindArgumentMethods
          
        private
          
        # Execute the stored prepared statement name and the stored bind
        # arguments instead of the SQL given.
        def execute(sql, opts={}, &block)
          super(prepared_statement_name, opts, &block)
        end
         
        # Same as execute, explicit due to intricacies of alias and super.
        def execute_dui(sql, opts={}, &block)
          super(prepared_statement_name, opts, &block)
        end
          
        # Same as execute, explicit due to intricacies of alias and super.
        def execute_insert(sql, opts={}, &block)
          super(prepared_statement_name, opts, &block)
        end
      end
        
      # Execute the given type of statement with the hash of values.
      def call(type, bind_vars={}, *values, &block)
        ps = to_prepared_statement(type, values)
        ps.extend(BindArgumentMethods)
        ps.call(bind_vars, &block)
      end
      
      # Yield a hash for each row in the dataset.
      def fetch_rows(sql)
        execute(sql) do |result|
          i = -1
          cps = db.conversion_procs
          type_procs = result.types.map{|t| cps[base_type_name(t)]}
          cols = result.columns.map{|c| i+=1; [output_identifier(c), i, type_procs[i]]}
          @columns = cols.map{|c| c.first}
          result.each do |values|
            row = {}
            cols.each do |name,i,type_proc|
              v = values[i]
              if type_proc && v.is_a?(String)
                v = type_proc.call(v)
              end
              row[name] = v
            end
            yield row
          end
        end
      end
      
      # Prepare the given type of query with the given name and store
      # it in the database.  Note that a new native prepared statement is
      # created on each call to this prepared statement.
      def prepare(type, name=nil, *values)
        ps = to_prepared_statement(type, values)
        ps.extend(PreparedStatementMethods)
        if name
          ps.prepared_statement_name = name
          db.prepared_statements[name] = ps
        end
        ps.prepared_sql
        ps
      end
      
      private
      
      # The base type name for a given type, without any parenthetical part.
      def base_type_name(t)
        (t =~ /^(.*?)\(/ ? $1 : t).downcase if t
      end

      # Quote the string using the adapter class method.
      def literal_string(v)
        "'#{::SQLite3::Database.quote(v)}'"
      end

      # SQLite uses a : before the name of the argument as a placeholder.
      def prepared_arg_placeholder
        PREPARED_ARG_PLACEHOLDER
      end
    end
  end
end