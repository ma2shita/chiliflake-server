ID generate server with ChiliFlake and Celluloid-io

QuickStart
----------

```
$ git clone https://github.com/ma2shita/chiliflake-server.git
$ cd chiliflake-server
$ bundle install --path .bundle/gems
$ bundle exec ruby app.rb
```

Stop is Ctrl+C

Other terminal:

```
$ ruby -rsocket -e 'puts UNIXSocket.open("\0/flake/1"){|s|s.readpartial(20)}'
522968898610401294
```

Reference
---------

### Server ###

```
bundle exec ruby app.rb [generator_id]
```


### Client sample ###

```
$ ruby -rsocket -e 'puts UNIXSocket.open("\0/flake/1"){|s|s.readpartial(20)}'
```

```
$ telnet localhost 1234
$ socat tcp-connect:localhost:1234 stdout
```

