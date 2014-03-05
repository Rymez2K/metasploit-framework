##
# This module requires Metasploit: http//metasploit.com/download
# Current source: https://github.com/rapid7/metasploit-framework
##

require 'msf/core'

class Metasploit3 < Msf::Auxiliary
  Rank = NormalRanking

  include Msf::Exploit::Remote::HttpServer::HTML

  def initialize(info={})
    super(update_info(info,
      'Name'           => "heaplib2 test",
      'Description'    => %q{
        This tests heaplib2
      },
      'License'        => MSF_LICENSE,
      'Author'         => [ 'sinn3r' ],
      'References'     => 
        [
          [ 'URL', 'http://metasploit.com' ]
        ],
      'Platform'       => 'win',
      'Targets'        =>
        [
          [ 'Automatic', {} ]
        ],
      'Privileged'     => false,
      'DisclosureDate' => "Mar 1 2014",
      'DefaultTarget'  => 0))
  end


  def on_request_uri(cli, request)
    spray = %Q|
    function log(msg) {
      console.log("[*] " + msg);
      Math.atan2(0x0101, msg);
    }

    log("Creating element div");
    var element = document.createElement("div");

    log("heapLib2");
    var heaplib = new heapLib2.ie(element, 0x80000);

    log("Creating spray");
    var spray = unescape("%u4141%u4141");
    while (spray.length < 0x20000) { spray += spray };

    log("spraying...");
    for (var i=0; i<0x400; i++) {
      heaplib.sprayalloc("userspray"+i, spray);
    }

    alert("free is about to happen");

    log("freeing...");
    for (var i=0; i<0x400; i++) {
      heaplib.free("userspray"+i);
    }
    |

    html = %Q|
    <html>
    <script>
    #{js_heaplib2(spray)}
    </script>
    </html>
    |

    print_status("Sending html")
    send_response(cli, html, {'Content-Type'=>'text/html'})
  end

  def run
    exploit
  end

end