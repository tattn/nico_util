# NicoUtil

Utility API for niconico (<http://www.nicovideo.jp>)

## Features

* Use official search API easily
* Sign in to niconico
* Get comments of video
* Get comments of live
* Get comments of illust
* Download an illust

## Install

Add the following line to Gemfile:

```
gem 'nico_util'
```

and run `bundle install` from your shell.

Or do the following:

```
$ gem install nico_util
```

## Usage

```ruby
require 'nico_util'
```

### Official Search API
```ruby
# See <http://search.nicovideo.jp/docs/api/search.html> for parameters.
p NicoUtil::Video.search 'ボカロ'
p NicoUtil::Illust.search '東方', 'filters[viewCounter][gte]': 10000, _limit: 3
p NicoUtil::Live.search 'ゲーム'
p NicoUtil::Blog.search '音楽'
p NicoUtil::Book.search 'らき☆すた'
p NicoUtil::Channel.search '歌ってみた'
p NicoUtil::Comic.search 'ラブコメ'
p NicoUtil::News.search 'アニメ'
```

### Sign in
```ruby
# write your account of niconico
email = 'niconico@example.com'
pass = 'password'

# login
nico = NicoUtil::login email, pass
```

### Video
```ruby
# get comments of a video
comments = nico.video('sm1097445').comments
comments.each do |comment|
  p comment
end
```

### Live
```ruby
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

### Illust
```ruby
# get an illust
illust = nico.illust('im3768140')

# get comments of an illust
p illust.comments

# get raw url of an illust
p illust.image_url

# download and save an illust
illust.save '/path/to/image'  # => /path/to/image.jpg
```

## Contributing

1. Fork it!
2. Create your feature branch: `git checkout -b my-new-feature`
3. Commit your changes: `git commit -am 'Add some feature'`
4. Push to the branch: `git push origin my-new-feature`
5. Submit a pull request :D

## License

NicoUtil is released under the MIT license. See LICENSE for details.
