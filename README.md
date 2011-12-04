# ConstantContact (1.0.0) [![Build Status](https://secure.travis-ci.org/tapajos/constantcontact.png)](http://travis-ci.org/tapajos/constantcontact)

## What is it?
This gem provides a set of classes to access information on [ConstantContact][h] via the published [API][api]:

    Contact, List, Activity, Campaign, Schedule.

All these classes are inherited from ActiveResouce::Base. Refer to the [ActiveResouce][ar] documentation for more information.

## Installing

    gem install constantcontact

### Dependencies (see <code>constantcontact.gemspec</code> or run <code>bundle check</code>)

 * Activeresource = 2.3.14

### Documentation

  I'm on [rdoc.info][rdoc]

### Configure your key
    
    require 'constantcontact'
    
    ConstantContact::Base.user = 'your_username'
    ConstantContact::Base.password = 'your_password'
    ConstantContact::Base.api_key = 'api-auth-token'

If you are using this in a Rails application, putting this code in a config/initializers/constantcontact.rb
file is recommended. See config_initializers_constantcontact.rb in the examples/ directory.

## Usage

    @contacts = ConstantContact::Contact.find(:all)
    
## License

This code is free to be used under the terms of the [MIT license][mit].

## Bugs, Issues, Kudos and Catcalls

Comments are welcome. Send your feedback through the [issue tracker on GitHub][i]

If you have fixes: Submit via pull requests. Do not include version changes to the 
version file. 

This is inspired by and closely based on original work by Timothy Case, https://github.com/timcase/constant_contact and contributions.

## Authors

* [Keith Salisbury][ktec]

## Contributors

* [Tim Case][timcase]
* [Laurence A. Lee][rubyjedi]
* [Ed Hickey][bassnode]


[ktec]: https://github.com/ktec
[timcase]: https://github.com/timcase
[rubyjedi]: https://github.com/rubyjedi
[basenode]: https://github.com/bassnode

[api]: http://developer.37signals.com/highrise
[ar]: http://api.rubyonrails.org/classes/ActiveResource/Base.html
[c]:  http://api.rubyonrails.org/classes/ActiveSupport/Cache
[cc]:  http://www.constantcontact.com/
[i]:  https://github.com/ktec/constantcontact/issues
[mit]:http://www.opensource.org/licenses/mit-license.php
[rdoc]: http://rdoc.info/projects/tapajos/highrise
