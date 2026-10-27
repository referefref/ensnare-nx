Adapted from https://github.com/ahoernecke/ensnare by Andy Hoernecke and Scott Behrens.

# ensnare-nx

ensnare-nx is Ensnare 0.1beta (last upstream commit 871b8a8, April 2017) adapted so that it installs and runs on current Ruby and Rails. The original is a Rails 3.2 engine: its gemspec pins `rails ~> 3.2.14`, which does not install on any supported Ruby, and it relies on APIs that Rails has since removed. The traps, responses, configuration format, violation model and dashboard are unchanged. Tested with Ruby 3.4.9 and Rails 8.1.4. The original README follows below.

## Changes from the original

* `ensnare.gemspec`: depends on `rails >= 7.1, < 9` (was `~> 3.2.14`) and no longer on `twitter-bootstrap-rails`; requires Ruby 3.2 or later.
* Form trap parameters: `alias_method_chain` (removed in Rails 5) is replaced by a module prepended to `ActionView::Base`. Current Rails builds every form (`form_tag`, `form_for` and `form_with`) through the private `extra_tags_for_form` helper, so the hidden trap parameters are added there, directly after the opening `<form>` tag (and the CSRF token). `form_with` is supported as well as `form_for`.
* Session data: Ensnare's own session entries use string keys (`session["ensnare"]["cookies"]`, `["params"]`, `["captcha_solved"]`) so that they survive the JSON cookie serializer that Rails uses by default.
* Parameter trap: nested `ActionController::Parameters` (no longer an `Enumerable`) are searched for trap parameters.
* `before_filter`/`skip_before_filter` become `before_action`/`skip_before_action`; `attr_accessible` is removed from the model; migrations are versioned (`ActiveRecord::Migration[4.2]`); routes declare their HTTP verbs; `render :text` becomes `render :html`; grouped counts in the metrics page use `order(...).count`; `require_dependency` calls are removed.
* Dashboard: the Bootstrap 2 assets loaded through `twitter-bootstrap-rails` and the jQuery/ZeroClipboard scripts are replaced by a small inline stylesheet, so the dashboard works with Propshaft, Sprockets or no asset pipeline. The copy-to-clipboard buttons on the configuration page are gone.
* Captcha response: the captcha page answers with the normal 404 page if the application does not include the `recaptcha` gem.
* The Rails 3.2 test suite and dummy application under `test/` are kept for reference but are not updated.

## Installing on current Rails

Add the gem to your application's Gemfile and install it:

```ruby
gem "ensnare", git: "https://github.com/referefref/ensnare-nx"
```

```shell
bundle install
bin/rails ensnare:install:migrations
bin/rails db:migrate
bin/rails g ensnare:install          # writes config/initializers/ensnare.rb
```

Add the filter to `app/controllers/application_controller.rb`:

```ruby
before_action :ensnare
```

Mount the engine and send unknown paths to Ensnare's routing-error trap at the end of `config/routes.rb`:

```ruby
mount Ensnare::Engine => "/ensnare", :as => "ensnare_engine"
match "*path", :to => "ensnare/violations#routing_error", via: :all
```

The `mass_assignment_sanitizer` step in the original instructions no longer applies: Rails uses strong parameters, and Ensnare removes its trap parameters from `params` before the controller sees them. Dashboard access is configured exactly as below (`dashboard_user_method` and `dashboard_authorization_method`); the methods must be available to controllers that inherit from `ActionController::Base`.

---

Ensnare
=======
Ensnare is packaged as a gem plugin for Ruby on Rails and was developed to allow configuring and deploying a basic malicious behavior detection and response scheme in less than ten minutes.

Ensnare uses a combination of [Honey Traps](https://github.com/ahoernecke/Ensnare/wiki#honey-traps) to entice malicious users, and a configurable suite of [Trap Responses](https://github.com/ahoernecke/Ensnare/wiki#response-types) to confuse, allude, delay, or stop an attacker.

Already heard about the tool and want to try it out?  Do it!

# Install #

Add the gem to your project's Gemfile:
```ruby
    gem 'ensnare', :git => 'git@github.com:ahoernecke/Ensnare.git'
```
Install the gem:
```shell
    bundle install
```
Run the migrations for Ensnare:
```shell
    rake ensnare:install:migrations
    rake db:migrate
```
Enable parameter tampering for your application by changing the mass_assignment_sanitizer:
```shell
    vi config/environments/<ENVIRONMENT>.rb
```  
Set config.active_record.mass_assignment_sanitizer to logger:
```ruby
    config.active_record.mass_assignment_sanitizer = :logger 
```   
Enable Ensnare in your application_controller.rb file:
```shell
    vi app/controllers/application_controller.rb
```    
Append the following filter below *protect_from_forgery* in your application_controller.rb file:
```ruby
    before_filter :ensnare
```
Add the following to the end of your routes.rb file:
```ruby
    mount Ensnare::Engine => "/ensnare", :as => "ensnare_engine" 
    match "*_", :to => "ensnare::violations#routing_error"
```
Create an Ensnare config file:
```shell
    rails g ensnare:install
```
Take a look at the example ensnare.rb file:
```shell    
    vi config/initializes/ensnare.rb
```
After you start your application, take a look at the dashboard:

    http://your-application.com/ensnare/dashboard/violations

In order to access the dashboard, this step needs to be performed.   

To prevent unnecessary users from accessing the dashboard, add the following to the `config/initalizers/ensnare.rb` file:
```ruby
  config.dashboard_user_method = :current_user
  config.dashboard_authorization_method = :admin?
```
 *NOTE:* you need to have a method defined to check if the user is the admin.
 
# Documentation #

[**Wiki**](https://github.com/ahoernecke/ensnare/wiki)

# Bugs #

[Dashboard CSS Issues in Firefox](https://github.com/ahoernecke/ensnare/issues/1)

# Resources #

http://books.google.com/books?id=flC9dFFLWIsC&pg=PT111&lpg=PT111&dq=honey+trap+mod+security&source=bl&ots=zKxJvehMpA&sig=E9qKn7L4siEk01caEF6wqofbbm8&hl=en&sa=X&ei=_iRUUoCRJKPiiwK8y4HIBA&ved=0CFUQ6AEwBg#v=onepage&q=honey trap mod security&f=false

## Contact ##
Created by [Andy Hoernecke](https://github.com/ahoernecke) and [Scott Behrens](https://github.com/sbehrens).

Feel free to reach out to us if you have questions or want to contribute to the project!
