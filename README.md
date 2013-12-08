# test-signet-rails

# IMPORTANT NOTICE FOR RAILS 3.2

You need to be looking at the [Rails 3.2](https://github.com/myitcv/test-signet-rails/tree/rails_3_2) branch.

The following instructions detail how to create a basic Rails 4 app that uses [`signet-rails`](https://github.com/myitcv/signet-rails). The app:

* configures [`signet`](https://github.com/google/signet) 
* utilises an `ActiveRecord` persistence store for each user's `access_token` and `refresh_token`
* prompt's the user for permission to access their profile details as well as a read-only version of their Google Calendars
* uses the the [Calendar API](https://developers.google.com/google-apps/calendar/) to pull back a list of the user's Google calendars

## To clone this project

[Register your app with Google](https://code.google.com/apis/console):

* create an OAuth 2.0 client ID (under 'API Access' tab)
* ensure the redirect URI includes `http://localhost:3000/signet/google/auth_callback`
* turn on the Calendar API (under 'Services' tab)

Then:

```bash
git clone git@github.com:myitcv/test-signet-rails.git
cd test-signet-rails
bundle exec rake db:migrate
export OAUTH_CLIENT_ID="client_id_from_google"
export OAUTH_CLIENT_SECRET="client_secret_from_google"
rails server
```

## Steps to reproduce this project

*Notice, when editing files it is safe to replace the entire contents of any pre-existing file with the contents below.*

Create a Rails app:

```bash
rails new test-signet-rails
```

Add the following lines to the resulting `Gemfile`:

```ruby
# add to Gemfile

gem 'google-api-client', :require => 'google/api_client'
gem 'signet-rails', '>= 0.0.6'
```

Install any missing gems:

```bash
bundle install
```


Setup session management, create a default controller+view, create a `User` model where we will store the `access_token` and `refresh_token`, commit changes to db:


```bash
rails generate controller home index
rails generate controller sessions
rails generate model User \
  uid:string 
rails generate model OAuth2Credential \
  name:string \
  user:references \
  signet:string
bundle exec rake db:migrate
```

Update the `User` model to reference `OAuth2Credential`:

```ruby
# app/model/user

class User < ActiveRecord::Base
  has_many :o_auth2_credentials, dependent: :destroy
end
```
Update the `OAuth2Credential` model to reference `User`:

```ruby
# app/model/o_auth2_credential

class OAuth2Credential < ActiveRecord::Base
  belongs_to :user
  serialize :signet, Hash
  validates_uniqueness_of :name, scope: :id
end
```

Configure routes in the app:


```ruby
# config/routes

TestSignetRails::Application.routes.draw do
  get "home/index"

  get '/signout' => 'sessions#destroy', as: :signout

  get '/signet/google/auth_callback' => 'sessions#create'

  root to: 'home#index'
end
```

Our sessions controller only needs to managed the concept of a user being 'logged in':

```ruby
# app/controllers/sessions_controller.rb

class SessionsController < ApplicationController
  def create
    user = request.env['signet.google.persistence_obj'].user
    session[:user_id] = user.id
    flash[:notice] = 'Signed In!'
    redirect_to root_url
  end

  def destroy
    session[:user_id] = nil
    flash[:notice] = 'Signed Out'
    redirect_to root_url
  end
end
```

Now [register your app with Google](https://code.google.com/apis/console):

* create an OAuth 2.0 client ID (under 'API Access' tab)
* ensure the redirect URI includes `http://localhost:3000/signet/google/auth_callback`
* turn on the Calendar API (under 'Services' tab)

Create an initialiser for `signet-rails`:

```ruby
# config/initializers/signet-rails.rb

Signet::Rails::Builder.set_default_options client_id: ENV['OAUTH_CLIENT_ID'],
  client_secret: ENV['OAUTH_CLIENT_SECRET']

Rails.application.config.middleware.use Signet::Rails::Builder do 
  provider name: :google, 
    type: :login,
    scope: [
    'https://www.googleapis.com/auth/userinfo.email',
    'https://www.googleapis.com/auth/userinfo.profile', 
    'https://www.googleapis.com/auth/calendar.readonly'
  ]
end
```

Set environment variables for the `client_id` and `client_secret` (using values from the Google API console):

```bash
export OAUTH_CLIENT_ID="client_id_from_google"
export OAUTH_CLIENT_SECRET="client_secret_from_google"
```

Define helper methods for the concept of `current_user` and `logged_in?`:

```ruby
# app/controllers/application_controller.rb

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  helper_method :current_user, :logged_in?

  def current_user
    u = nil
    if !!session[:user_id]
      begin
        u = User.find(session[:user_id])
      rescue ActiveRecord::RecordNotFound => e
        session[:user_id] = nil
      end
    end
    u
  end

  def logged_in?
    !!current_user
  end
end
```

Our default page (`home#index`) needs a list of the user's Google Calendars. In the `HomeController` we use the `Signet::Rails::Factory` to create a new authentication client, initialise a new `Google::APIClient` and then start pulling our calendar information:

```ruby
# app/controllers/home_controller.rb

class HomeController < ApplicationController
  def index
    if logged_in?
      auth = Signet::Rails::Factory.create_from_env :google, request.env
      client = Google::APIClient.new
      client.authorization = auth
      service = client.discovered_api('calendar', 'v3')
      @result = client.execute(
        :api_method => service.calendar_list.list,
        :parameters => {},
        :headers => {'Content-Type' => 'application/json'}
      )
    end
  end
end
```

Update the view to display the list of calendars (in `debug` form):

```html

<!-- app/views/home/index.html.erb -->

<% if logged_in? %>

  <h1>Logged in</h1>

  <p><%= link_to 'Sign out', signout_path %><p>

  <%= debug @result.data %>

<% else %>

  <%= link_to 'Sign in', '/signet/google/auth' %>

<% end %>
```

Run the test application:

```bash
rails server
```

Voila. 
