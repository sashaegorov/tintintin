# Tintintin (ex. *Scanty*), a small blog

_Tintintin_ is simple blogging software. It’s small and easily modifiable. _Tintintin_ is former [Scanty](https://github.com/adamwiggins/scanty). I <del>still changing</del> have changed some of features and most of under hood stuff.

## Features
 - Posts (OMG!)
 - [Disqus](http://www.disqus.com) comments
 - Markdown (via Discount) and Textile (via RedCloth)
 - Atom feed
 - Tags

**TODO:** Perform update according list below

 1. Review features
 2. Link each feature to related Cucumber feature file i.e. `Posts` item to `post.feature`.

## Guts
 - **Sinatra** as web framework
 - **Sequel** as ORM
 - <del>Erb</del> **Haml** as markup language
 - <del>Bootstrap</del> **Zurb Foundation** as front end framework (work in progress)

## Get it
Clone! All dependencies carefully managed by Bundler with care:

    $ git clone https://github.com/qatsi/tintintin
    $ bundle install

## Run it
Following run options available:

    $ rake start # the same as above
    $ rackup # http://localhost:9292    
    $ ruby main.rb # http://localhost:4567

Also available `rake start:background` and `rake stop` tasks.

Finally, log in using the password you selected, then click `New Post`. The rest should be self-explanatory.

## Customize it

There are no themes or settings beyond the basic ones in the Blog struct. Just edit the CSS or the code as you see fit.

## Import data
Some kinds of data can be imported easily, take a look at the rake task **:import** for an example of loading from a YAML file with field names that match the database schema.

TODO: Example

## Database

The default is a SQLite, file named `blog.db`. To use something else, set DATABASE_URL in your environment when running the app, i.e.:

    $ DATABASE_URL='mysql://localhost/myblog' ruby main.rb

Don't modify the Sequel.connect statement at the top of main.rb. It's bad.
All necessary tables will be created automatically when the server is executed.

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