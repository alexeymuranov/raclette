# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Raclette::Application.initialize!

# Custom global constants
ACCEPTABLE_EMAIL_ADDRESS_FORMAT =
    /\A([A-Za-z\d\!\#\$\%\&\'\*\+\-\/\=\?\^\_\`\{\|\}\~]+\.)*
        [A-Za-z\d\!\#\$\%\&\'\*\+\-\/\=\?\^\_\`\{\|\}\~]+
     @([a-z\d\-]+\.)+
       [a-z\d\-]+\z/x
