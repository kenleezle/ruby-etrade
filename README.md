ruby-etrade
===========

Library for interacting with etrade api

Create a file called consumer_token.rb.  This file should have your consumer key which was given to you by etrade.  Its contents should be in the following format.
> CONSUMER_TOKEN = {
>   :token => "XXXXXXXXXX",
>   :secret => "XXXXXXXXXX"
> }

To authorize the library to use your e-trade credentials, run the following command and follow the instructions:

> % ruby get_access_token.rb

Test that it works by running the test program.  This program will list the contents of the Get Account List command.

> % ruby test_get_account_list.rb
