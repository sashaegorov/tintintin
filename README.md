# Tintintin (ex. *Scanty*), a small blog

_Tintintin_ is understandable blogging software. It’s small and easily modifiable. _Tintintin_ is former [Scanty](https://github.com/adamwiggins/scanty). I <del>still changing</del> have changed some of features and most of under hood stuff.

## Features
* Posts (OMG!)
* Tags
* [Disqus](http://www.disqus.com) comments
* Markdown (via Discount) and Textile (via RedCloth)
* Atom feed

## Guts
* Haml
* _Sinatra_ as web framework
* _Sequel_ as ORM
* <del>Zurb Foundation</del>

## Get it
Clone! All dependencies managed by Bundler with care:

    $ git clone https://github.com/qatsi/tintintin
    $ bundle install

## Run it

[Run](http://localhost:4567) the server quick and dirty:

    $ ruby main.rb

[Or](http://localhost:9292) using `rackup`

    $ rackup 

Log in with the password you selected, then click `New Post`. The rest should be self-explanatory.

## Customize it

There are no themes or settings beyond the basic ones in the Blog struct. Just edit the CSS or the code as you see fit.

## Import data
Some kinds of data can be imported easily, take a look at the rake task **:import** for an example of loading from a YAML file with field names that match the database schema.

TODO: Example

## Database

The default is a SQLite file named blog.db. To use something else, see
config.yml.sample or change uri at the top of main.rb

The database will be created automatically when the server is executed.
## Database

The default is a SQLite file named blog.db. To use something else, set DATABASE_URL in your environment when running the app, i.e.:

$ DATABASE_URL='mysql://localhost/myblog' ruby main.rb
Or, modify the Sequel.connect statement at the top of main.rb.

The database will be created automatically when the server is executed.

## Add comments
There are no comments by default. If you wish to activate comments, create an account and a website on [Disqus](http://www.disqus.com) and enter the website shortname as the **:disqus_shortname** value in the Blog config struct.
TODO: Check this!

## Todo
- **Code**
 - Simplify, simplify, simplify…
 - Improve, improve, improve…
 - Replace _spec_ by _cucumber_
 - Review _Gemfile_
 - Clean up _Rakefile_
 - Use `tags` feature somewhere
 - Make config more accessable

- **Documentation**
 - Carefully check and update this _README.md_
 - Translate Readme to Russian
 - Add links for everything which is linkable
 - Add Rakfile tasks short explanation

- **Go i18n**
 - Extract messages 
 - Translate strings to Russian 

## Meta
Original [Scanty](http://github.com/adamwiggins/scanty) was written by _Adam Wiggins_. Thanks, Adam!
Patches for Scanty were contributed by: _Christopher Swenson_, _S. Brent Faulkner_, _and Stephen Eley_, _Thomas Yang_.

Released under the [MIT License](http://www.opensource.org/licenses/mit-license.php).