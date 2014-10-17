require "bundler"
Bundler.require(:default)
require "logger"

$generator_id = (ARGV[0] || (Time.now.to_i % 1024)).to_i
$flake = ChiliFlake.new($generator_id)

$generate_counter = 0

$logger = Logger.new(STDERR)

class BaseServer
  include Celluloid::IO
  finalizer :finalize

  def initialize(_)
    $logger.info "ID generator `ChiliFlake` server start: generator_id is #{$generator_id}, process_id is #{$$}"
  end

  def finalize
    @server.close if @server
    $logger.info "ID generator `ChiliFlake` server end"
  end

  def run
    loop { async.handle_connection @server.accept }
  end

  def handle_connection(socket)
    socket.write $flake.generate.to_s
    $generate_counter += 1
  rescue EOFError
    nil
  ensure
    socket.close
  end
end

class UServer < BaseServer
  attr_reader :socket_path, :server

  def initialize(socket_path)
    super
    $logger.info "  Listen UNIX Domain Socket on \`\\0/fleak/#{$generator_id}\`"
    @socket_path = socket_path
    @server = UNIXServer.new(@socket_path)
    async.run
  end

  def finalize
    super
    File.delete(@socket_path) if File.exists?(@socket_path)
  end
end

class TServer < BaseServer
  attr_reader :server

  def initialize(opts)
    $logger.info "  Listen TCP on \`1234\`"
    @server = TCPServer.new(opts[:host], opts[:port])
    async.run
  end
end

sv1 = UServer.supervise "\0/flake/#{$generator_id}"
sv1 = TServer.supervise :host => "127.0.0.1", :port => 1234
trap(:INT) {
  sv1.terminate
  sv2.terminate
  exit
}
trap(:USR1) {
  STDERR.puts "counter: #{$generate_counter}" # logger `log writing failed. can't be called from trap context`
}
sleep

