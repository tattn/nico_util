# NicoUtil

Utility APIs for niconico (<http://www.nicovideo.jp>)

## Features

* Sign in to niconico
* Get comments of video
* Get comments of live

## Install

Add the following line to Gemfile:

```
gem 'nico-util', github: "tattn/nico-util"
```

and run `bundle install` from your shell.

Or do the following:

```
$ gem install specific_install
$ gem specific_install -l 'git://github.com/tattn/nico-util.git'
```

## Usage

```ruby
require 'nico-util'

# write your account of niconico
email = 'niconico@example.com'
pass = 'password'

# login
nico = NicoUtil::login email, pass

# get and show comments of a video
comments = nico.video('sm1097445').comments
comments.each do |comment|
  p comment
end

# connect to a live and show data
nico.live('lv242616226').connect do |status, data|
  case status
  when :comment
    puts data
  when :command
    puts data
  when :disconnect
    puts 'disconnect'
  end
end
```

## Contributing

1. Fork it!
2. Create your feature branch: `git checkout -b my-new-feature`
3. Commit your changes: `git commit -am 'Add some feature'`
4. Push to the branch: `git push origin my-new-feature`
5. Submit a pull request :D

## License

NicoUtil is released under the MIT license. See LICENSE for details.