#!/usr/bin/perl

use strict;
use warnings;
use NGCP::Rtpengine::Test;
use NGCP::Rtpclient::SRTP;
use NGCP::Rtpengine::AutoTest;
use Test::More;
use POSIX;


(POSIX::uname())[1] eq 'moose' or exit(); # long duration tests


autotest_start(qw(--config-file=none -t -1 -i 203.0.113.1 -i 2001:db8:4321::1
			-n 2223 -c 12345 -f -L 7 -E -u 2222))
		or die;


my ($sock_a, $sock_b, $sock_ax, $sock_bx,
	$port_a, $port_ax, $port_b, $port_bx,
	$ssrc, $resp, $srtp_ctx_a, $srtp_ctx_b, @ret1, @ret2);




($sock_a, $sock_ax, $sock_b, $sock_bx) = new_call(
	[qw(198.51.100.1 2010)],
	[qw(198.51.100.1 2011)],
	[qw(198.51.100.3 2012)],
	[qw(198.51.100.3 2013)],
);

($port_a, $port_ax) = offer('packet loss control', { ICE => 'remove', replace => ['origin'],
	flags => ['generate RTCP'] }, <<SDP);
v=0
o=- 1545997027 1 IN IP4 198.51.100.1
s=tester
t=0 0
m=audio 2010 RTP/AVP 0
c=IN IP4 198.51.100.1
a=sendrecv
----------------------------------
v=0
o=- 1545997027 1 IN IP4 203.0.113.1
s=tester
t=0 0
m=audio PORT RTP/AVP 0
c=IN IP4 203.0.113.1
a=rtpmap:0 PCMU/8000
a=sendrecv
a=rtcp:PORT
SDP

($port_b, $port_bx) = answer('packet loss control', { ICE => 'remove', replace => ['origin'] }, <<SDP);
v=0
o=- 1545997027 1 IN IP4 198.51.100.3
s=tester
t=0 0
m=audio 2012 RTP/AVP 0
c=IN IP4 198.51.100.3
a=sendrecv
--------------------------------------
v=0
o=- 1545997027 1 IN IP4 203.0.113.1
s=tester
t=0 0
m=audio PORT RTP/AVP 0
c=IN IP4 203.0.113.1
a=rtpmap:0 PCMU/8000
a=sendrecv
a=rtcp:PORT
SDP

snd($sock_a, $port_b, rtp(0, 1000, 3000, 0x1234, "\x00" x 160));
rcv($sock_b, $port_a, rtpm(0, 1000, 3000, 0x1234, "\x00" x 160));
snd($sock_a, $port_b, rtp(0, 1001, 3160, 0x1234, "\x00" x 160));
rcv($sock_b, $port_a, rtpm(0, 1001, 3160, 0x1234, "\x00" x 160));
snd($sock_a, $port_b, rtp(0, 1002, 3320, 0x1234, "\x00" x 160));
rcv($sock_b, $port_a, rtpm(0, 1002, 3320, 0x1234, "\x00" x 160));
snd($sock_a, $port_b, rtp(0, 1003, 3480, 0x1234, "\x00" x 160));
rcv($sock_b, $port_a, rtpm(0, 1003, 3480, 0x1234, "\x00" x 160));
snd($sock_a, $port_b, rtp(0, 1004, 3640, 0x1234, "\x00" x 160));
rcv($sock_b, $port_a, rtpm(0, 1004, 3640, 0x1234, "\x00" x 160));
snd($sock_a, $port_b, rtp(0, 1005, 3800, 0x1234, "\x00" x 160));
rcv($sock_b, $port_a, rtpm(0, 1005, 3800, 0x1234, "\x00" x 160));
snd($sock_a, $port_b, rtp(0, 1006, 3960, 0x1234, "\x00" x 160));
rcv($sock_b, $port_a, rtpm(0, 1006, 3960, 0x1234, "\x00" x 160));
snd($sock_a, $port_b, rtp(0, 1007, 4120, 0x1234, "\x00" x 160));
rcv($sock_b, $port_a, rtpm(0, 1007, 4120, 0x1234, "\x00" x 160));
snd($sock_a, $port_b, rtp(0, 1008, 4280, 0x1234, "\x00" x 160));
rcv($sock_b, $port_a, rtpm(0, 1008, 4280, 0x1234, "\x00" x 160));
snd($sock_a, $port_b, rtp(0, 1009, 4440, 0x1234, "\x00" x 160));
rcv($sock_b, $port_a, rtpm(0, 1009, 4440, 0x1234, "\x00" x 160));
snd($sock_a, $port_b, rtp(0, 1010, 4600, 0x1234, "\x00" x 160));
rcv($sock_b, $port_a, rtpm(0, 1010, 4600, 0x1234, "\x00" x 160));
snd($sock_a, $port_b, rtp(0, 1011, 4760, 0x1234, "\x00" x 160));
rcv($sock_b, $port_a, rtpm(0, 1011, 4760, 0x1234, "\x00" x 160));
snd($sock_a, $port_b, rtp(0, 1012, 4920, 0x1234, "\x00" x 160));
rcv($sock_b, $port_a, rtpm(0, 1012, 4920, 0x1234, "\x00" x 160));
snd($sock_a, $port_b, rtp(0, 1013, 5080, 0x1234, "\x00" x 160));
rcv($sock_b, $port_a, rtpm(0, 1013, 5080, 0x1234, "\x00" x 160));
snd($sock_a, $port_b, rtp(0, 1014, 5240, 0x1234, "\x00" x 160));
rcv($sock_b, $port_a, rtpm(0, 1014, 5240, 0x1234, "\x00" x 160));
snd($sock_a, $port_b, rtp(0, 1015, 5400, 0x1234, "\x00" x 160));
rcv($sock_b, $port_a, rtpm(0, 1015, 5400, 0x1234, "\x00" x 160));
snd($sock_a, $port_b, rtp(0, 1016, 5560, 0x1234, "\x00" x 160));
rcv($sock_b, $port_a, rtpm(0, 1016, 5560, 0x1234, "\x00" x 160));
snd($sock_a, $port_b, rtp(0, 1017, 5720, 0x1234, "\x00" x 160));
rcv($sock_b, $port_a, rtpm(0, 1017, 5720, 0x1234, "\x00" x 160));
snd($sock_a, $port_b, rtp(0, 1018, 5880, 0x1234, "\x00" x 160));
rcv($sock_b, $port_a, rtpm(0, 1018, 5880, 0x1234, "\x00" x 160));
snd($sock_a, $port_b, rtp(0, 1019, 6040, 0x1234, "\x00" x 160));
rcv($sock_b, $port_a, rtpm(0, 1019, 6040, 0x1234, "\x00" x 160));
snd($sock_a, $port_b, rtp(0, 1020, 6200, 0x1234, "\x00" x 160));
rcv($sock_b, $port_a, rtpm(0, 1020, 6200, 0x1234, "\x00" x 160));
snd($sock_a, $port_b, rtp(0, 1021, 6360, 0x1234, "\x00" x 160));
rcv($sock_b, $port_a, rtpm(0, 1021, 6360, 0x1234, "\x00" x 160));
snd($sock_a, $port_b, rtp(0, 1022, 6520, 0x1234, "\x00" x 160));
rcv($sock_b, $port_a, rtpm(0, 1022, 6520, 0x1234, "\x00" x 160));
snd($sock_a, $port_b, rtp(0, 1023, 6680, 0x1234, "\x00" x 160));
rcv($sock_b, $port_a, rtpm(0, 1023, 6680, 0x1234, "\x00" x 160));
snd($sock_a, $port_b, rtp(0, 1024, 6840, 0x1234, "\x00" x 160));
rcv($sock_b, $port_a, rtpm(0, 1024, 6840, 0x1234, "\x00" x 160));
snd($sock_a, $port_b, rtp(0, 1025, 7000, 0x1234, "\x00" x 160));
rcv($sock_b, $port_a, rtpm(0, 1025, 7000, 0x1234, "\x00" x 160));
snd($sock_a, $port_b, rtp(0, 1026, 7160, 0x1234, "\x00" x 160));
rcv($sock_b, $port_a, rtpm(0, 1026, 7160, 0x1234, "\x00" x 160));
snd($sock_a, $port_b, rtp(0, 1027, 7320, 0x1234, "\x00" x 160));
rcv($sock_b, $port_a, rtpm(0, 1027, 7320, 0x1234, "\x00" x 160));
snd($sock_a, $port_b, rtp(0, 1028, 7480, 0x1234, "\x00" x 160));
rcv($sock_b, $port_a, rtpm(0, 1028, 7480, 0x1234, "\x00" x 160));
snd($sock_a, $port_b, rtp(0, 1029, 7640, 0x1234, "\x00" x 160));
rcv($sock_b, $port_a, rtpm(0, 1029, 7640, 0x1234, "\x00" x 160));
snd($sock_a, $port_b, rtp(0, 1030, 7800, 0x1234, "\x00" x 160));
rcv($sock_b, $port_a, rtpm(0, 1030, 7800, 0x1234, "\x00" x 160));
snd($sock_a, $port_b, rtp(0, 1031, 7960, 0x1234, "\x00" x 160));
rcv($sock_b, $port_a, rtpm(0, 1031, 7960, 0x1234, "\x00" x 160));
snd($sock_a, $port_b, rtp(0, 1032, 8120, 0x1234, "\x00" x 160));
rcv($sock_b, $port_a, rtpm(0, 1032, 8120, 0x1234, "\x00" x 160));
snd($sock_a, $port_b, rtp(0, 1033, 8280, 0x1234, "\x00" x 160));
rcv($sock_b, $port_a, rtpm(0, 1033, 8280, 0x1234, "\x00" x 160));
snd($sock_a, $port_b, rtp(0, 1034, 8440, 0x1234, "\x00" x 160));
rcv($sock_b, $port_a, rtpm(0, 1034, 8440, 0x1234, "\x00" x 160));
snd($sock_a, $port_b, rtp(0, 1035, 8600, 0x1234, "\x00" x 160));
rcv($sock_b, $port_a, rtpm(0, 1035, 8600, 0x1234, "\x00" x 160));
snd($sock_a, $port_b, rtp(0, 1036, 8760, 0x1234, "\x00" x 160));
rcv($sock_b, $port_a, rtpm(0, 1036, 8760, 0x1234, "\x00" x 160));
snd($sock_a, $port_b, rtp(0, 1037, 8920, 0x1234, "\x00" x 160));
rcv($sock_b, $port_a, rtpm(0, 1037, 8920, 0x1234, "\x00" x 160));

snd($sock_b, $port_a, rtp(0, 2000, 4000, 0x161c, "\x00" x 160));
rcv($sock_a, $port_b, rtpm(0, 2000, 4000, 0x161c, "\x00" x 160));
snd($sock_b, $port_a, rtp(0, 2001, 4160, 0x161c, "\x00" x 160));
rcv($sock_a, $port_b, rtpm(0, 2001, 4160, 0x161c, "\x00" x 160));
snd($sock_b, $port_a, rtp(0, 2002, 4320, 0x161c, "\x00" x 160));
rcv($sock_a, $port_b, rtpm(0, 2002, 4320, 0x161c, "\x00" x 160));
snd($sock_b, $port_a, rtp(0, 2003, 4480, 0x161c, "\x00" x 160));
rcv($sock_a, $port_b, rtpm(0, 2003, 4480, 0x161c, "\x00" x 160));
snd($sock_b, $port_a, rtp(0, 2004, 4640, 0x161c, "\x00" x 160));
rcv($sock_a, $port_b, rtpm(0, 2004, 4640, 0x161c, "\x00" x 160));
snd($sock_b, $port_a, rtp(0, 2005, 4800, 0x161c, "\x00" x 160));
rcv($sock_a, $port_b, rtpm(0, 2005, 4800, 0x161c, "\x00" x 160));
snd($sock_b, $port_a, rtp(0, 2006, 4960, 0x161c, "\x00" x 160));
rcv($sock_a, $port_b, rtpm(0, 2006, 4960, 0x161c, "\x00" x 160));
snd($sock_b, $port_a, rtp(0, 2007, 5120, 0x161c, "\x00" x 160));
rcv($sock_a, $port_b, rtpm(0, 2007, 5120, 0x161c, "\x00" x 160));
snd($sock_b, $port_a, rtp(0, 2008, 5280, 0x161c, "\x00" x 160));
rcv($sock_a, $port_b, rtpm(0, 2008, 5280, 0x161c, "\x00" x 160));
snd($sock_b, $port_a, rtp(0, 2009, 5440, 0x161c, "\x00" x 160));
rcv($sock_a, $port_b, rtpm(0, 2009, 5440, 0x161c, "\x00" x 160));
snd($sock_b, $port_a, rtp(0, 2010, 5600, 0x161c, "\x00" x 160));
rcv($sock_a, $port_b, rtpm(0, 2010, 5600, 0x161c, "\x00" x 160));
snd($sock_b, $port_a, rtp(0, 2011, 5760, 0x161c, "\x00" x 160));
rcv($sock_a, $port_b, rtpm(0, 2011, 5760, 0x161c, "\x00" x 160));
snd($sock_b, $port_a, rtp(0, 2012, 5920, 0x161c, "\x00" x 160));
rcv($sock_a, $port_b, rtpm(0, 2012, 5920, 0x161c, "\x00" x 160));
snd($sock_b, $port_a, rtp(0, 2013, 6080, 0x161c, "\x00" x 160));
rcv($sock_a, $port_b, rtpm(0, 2013, 6080, 0x161c, "\x00" x 160));
snd($sock_b, $port_a, rtp(0, 2014, 6240, 0x161c, "\x00" x 160));
rcv($sock_a, $port_b, rtpm(0, 2014, 6240, 0x161c, "\x00" x 160));
snd($sock_b, $port_a, rtp(0, 2015, 6400, 0x161c, "\x00" x 160));
rcv($sock_a, $port_b, rtpm(0, 2015, 6400, 0x161c, "\x00" x 160));
snd($sock_b, $port_a, rtp(0, 2016, 6560, 0x161c, "\x00" x 160));
rcv($sock_a, $port_b, rtpm(0, 2016, 6560, 0x161c, "\x00" x 160));
snd($sock_b, $port_a, rtp(0, 2017, 6720, 0x161c, "\x00" x 160));
rcv($sock_a, $port_b, rtpm(0, 2017, 6720, 0x161c, "\x00" x 160));
snd($sock_b, $port_a, rtp(0, 2018, 6880, 0x161c, "\x00" x 160));
rcv($sock_a, $port_b, rtpm(0, 2018, 6880, 0x161c, "\x00" x 160));
snd($sock_b, $port_a, rtp(0, 2019, 7040, 0x161c, "\x00" x 160));
rcv($sock_a, $port_b, rtpm(0, 2019, 7040, 0x161c, "\x00" x 160));
snd($sock_b, $port_a, rtp(0, 2020, 7200, 0x161c, "\x00" x 160));
rcv($sock_a, $port_b, rtpm(0, 2020, 7200, 0x161c, "\x00" x 160));
snd($sock_b, $port_a, rtp(0, 2021, 7360, 0x161c, "\x00" x 160));
rcv($sock_a, $port_b, rtpm(0, 2021, 7360, 0x161c, "\x00" x 160));
snd($sock_b, $port_a, rtp(0, 2022, 7520, 0x161c, "\x00" x 160));
rcv($sock_a, $port_b, rtpm(0, 2022, 7520, 0x161c, "\x00" x 160));
snd($sock_b, $port_a, rtp(0, 2023, 7680, 0x161c, "\x00" x 160));
rcv($sock_a, $port_b, rtpm(0, 2023, 7680, 0x161c, "\x00" x 160));
snd($sock_b, $port_a, rtp(0, 2024, 7840, 0x161c, "\x00" x 160));
rcv($sock_a, $port_b, rtpm(0, 2024, 7840, 0x161c, "\x00" x 160));
snd($sock_b, $port_a, rtp(0, 2025, 8000, 0x161c, "\x00" x 160));
rcv($sock_a, $port_b, rtpm(0, 2025, 8000, 0x161c, "\x00" x 160));
snd($sock_b, $port_a, rtp(0, 2026, 8160, 0x161c, "\x00" x 160));
rcv($sock_a, $port_b, rtpm(0, 2026, 8160, 0x161c, "\x00" x 160));
snd($sock_b, $port_a, rtp(0, 2027, 8320, 0x161c, "\x00" x 160));
rcv($sock_a, $port_b, rtpm(0, 2027, 8320, 0x161c, "\x00" x 160));
snd($sock_b, $port_a, rtp(0, 2028, 8480, 0x161c, "\x00" x 160));
rcv($sock_a, $port_b, rtpm(0, 2028, 8480, 0x161c, "\x00" x 160));
snd($sock_b, $port_a, rtp(0, 2029, 8640, 0x161c, "\x00" x 160));
rcv($sock_a, $port_b, rtpm(0, 2029, 8640, 0x161c, "\x00" x 160));
snd($sock_b, $port_a, rtp(0, 2030, 8800, 0x161c, "\x00" x 160));
rcv($sock_a, $port_b, rtpm(0, 2030, 8800, 0x161c, "\x00" x 160));
snd($sock_b, $port_a, rtp(0, 2031, 8960, 0x161c, "\x00" x 160));
rcv($sock_a, $port_b, rtpm(0, 2031, 8960, 0x161c, "\x00" x 160));
snd($sock_b, $port_a, rtp(0, 2032, 9120, 0x161c, "\x00" x 160));
rcv($sock_a, $port_b, rtpm(0, 2032, 9120, 0x161c, "\x00" x 160));
snd($sock_b, $port_a, rtp(0, 2033, 9280, 0x161c, "\x00" x 160));
rcv($sock_a, $port_b, rtpm(0, 2033, 9280, 0x161c, "\x00" x 160));
snd($sock_b, $port_a, rtp(0, 2034, 9440, 0x161c, "\x00" x 160));
rcv($sock_a, $port_b, rtpm(0, 2034, 9440, 0x161c, "\x00" x 160));
snd($sock_b, $port_a, rtp(0, 2035, 9600, 0x161c, "\x00" x 160));
rcv($sock_a, $port_b, rtpm(0, 2035, 9600, 0x161c, "\x00" x 160));
snd($sock_b, $port_a, rtp(0, 2036, 9760, 0x161c, "\x00" x 160));
rcv($sock_a, $port_b, rtpm(0, 2036, 9760, 0x161c, "\x00" x 160));
snd($sock_b, $port_a, rtp(0, 2037, 9920, 0x161c, "\x00" x 160));
rcv($sock_a, $port_b, rtpm(0, 2037, 9920, 0x161c, "\x00" x 160));

# wait for RTCP

sleep(7);

rcv($sock_bx, $port_ax, qr/^
	\x81 # version 2, 1 SSRC
	\xc8 # PT=200
	\x00\x0c # length
	\x00\x00\x12\x34 # sender SSRC
	........ # NTP TS
	\x00\x00\x22\xd8 # RTP TS
	\x00\x00\x00\x26 # packet count
	\x00\x00\x19\x88 # octet count
	\x00\x00\x16\x1c # source SSRC
	\x00\x00\x00\x00 # lost count
	\x00\x00\x07\xf5 # highest seq
	.... # jitter
	.... # LSR
	.... # DLSR
	\x81 # version 2, 1 SSRC
	\xca # PT=202
	\x00\x05 # length
	\x00\x00\x12\x34 # SSRC
	\x01 # SDES CNAME
	\x0c # length
	............ # instance ID
	\x00\x00$/sx);
rcv($sock_ax, $port_bx, qr/^
	\x81 # version 2, 1 SSRC
	\xc8 # PT=200
	\x00\x0c # length
	\x00\x00\x16\x1c # sender SSRC
	........ # NTP TS
	\x00\x00\x26\xc0 # RTP TS
	\x00\x00\x00\x26 # packet count
	\x00\x00\x19\x88 # octet count
	\x00\x00\x12\x34 # source SSRC
	\x00\x00\x00\x00 # lost count
	\x00\x00\x04\x0d # highest seq
	.... # jitter
	.... # LSR
	.... # DLSR
	\x81 # version 2, 1 SSRC
	\xca # PT=202
	\x00\x05 # length
	\x00\x00\x16\x1c # SSRC
	\x01 # SDES CNAME
	\x0c # length
	............ # instance ID
	\x00\x00$/sx);

$resp = rtpe_req('delete', 'packet loss', { 'from-tag' => ft() });


($sock_a, $sock_ax, $sock_b, $sock_bx) = new_call(
	[qw(198.51.100.1 2014)],
	[qw(198.51.100.1 2015)],
	[qw(198.51.100.3 2016)],
	[qw(198.51.100.3 2017)],
);

($port_a, $port_ax) = offer('packet loss control', { ICE => 'remove', replace => ['origin'],
	flags => ['generate RTCP'] }, <<SDP);
v=0
o=- 1545997027 1 IN IP4 198.51.100.1
s=tester
t=0 0
m=audio 2014 RTP/AVP 0
c=IN IP4 198.51.100.1
a=sendrecv
----------------------------------
v=0
o=- 1545997027 1 IN IP4 203.0.113.1
s=tester
t=0 0
m=audio PORT RTP/AVP 0
c=IN IP4 203.0.113.1
a=rtpmap:0 PCMU/8000
a=sendrecv
a=rtcp:PORT
SDP

($port_b, $port_bx) = answer('packet loss', { ICE => 'remove', replace => ['origin'] }, <<SDP);
v=0
o=- 1545997027 1 IN IP4 198.51.100.3
s=tester
t=0 0
m=audio 2016 RTP/AVP 0
c=IN IP4 198.51.100.3
a=sendrecv
--------------------------------------
v=0
o=- 1545997027 1 IN IP4 203.0.113.1
s=tester
t=0 0
m=audio PORT RTP/AVP 0
c=IN IP4 203.0.113.1
a=rtpmap:0 PCMU/8000
a=sendrecv
a=rtcp:PORT
SDP

snd($sock_a, $port_b, rtp(0, 1000, 3000, 0x1234, "\x00" x 160));
rcv($sock_b, $port_a, rtpm(0, 1000, 3000, 0x1234, "\x00" x 160));
snd($sock_a, $port_b, rtp(0, 1001, 3160, 0x1234, "\x00" x 160));
rcv($sock_b, $port_a, rtpm(0, 1001, 3160, 0x1234, "\x00" x 160));
snd($sock_a, $port_b, rtp(0, 1003, 3480, 0x1234, "\x00" x 160));
rcv($sock_b, $port_a, rtpm(0, 1003, 3480, 0x1234, "\x00" x 160));
snd($sock_a, $port_b, rtp(0, 1004, 3640, 0x1234, "\x00" x 160));
rcv($sock_b, $port_a, rtpm(0, 1004, 3640, 0x1234, "\x00" x 160));
snd($sock_a, $port_b, rtp(0, 1005, 3800, 0x1234, "\x00" x 160));
rcv($sock_b, $port_a, rtpm(0, 1005, 3800, 0x1234, "\x00" x 160));
snd($sock_a, $port_b, rtp(0, 1006, 3960, 0x1234, "\x00" x 160));
rcv($sock_b, $port_a, rtpm(0, 1006, 3960, 0x1234, "\x00" x 160));
snd($sock_a, $port_b, rtp(0, 1007, 4120, 0x1234, "\x00" x 160));
rcv($sock_b, $port_a, rtpm(0, 1007, 4120, 0x1234, "\x00" x 160));
snd($sock_a, $port_b, rtp(0, 1008, 4280, 0x1234, "\x00" x 160));
rcv($sock_b, $port_a, rtpm(0, 1008, 4280, 0x1234, "\x00" x 160));
snd($sock_a, $port_b, rtp(0, 1009, 4440, 0x1234, "\x00" x 160));
rcv($sock_b, $port_a, rtpm(0, 1009, 4440, 0x1234, "\x00" x 160));
snd($sock_a, $port_b, rtp(0, 1010, 4600, 0x1234, "\x00" x 160));
rcv($sock_b, $port_a, rtpm(0, 1010, 4600, 0x1234, "\x00" x 160));
snd($sock_a, $port_b, rtp(0, 1011, 4760, 0x1234, "\x00" x 160));
rcv($sock_b, $port_a, rtpm(0, 1011, 4760, 0x1234, "\x00" x 160));
snd($sock_a, $port_b, rtp(0, 1012, 4920, 0x1234, "\x00" x 160));
rcv($sock_b, $port_a, rtpm(0, 1012, 4920, 0x1234, "\x00" x 160));
snd($sock_a, $port_b, rtp(0, 1013, 5080, 0x1234, "\x00" x 160));
rcv($sock_b, $port_a, rtpm(0, 1013, 5080, 0x1234, "\x00" x 160));
snd($sock_a, $port_b, rtp(0, 1014, 5240, 0x1234, "\x00" x 160));
rcv($sock_b, $port_a, rtpm(0, 1014, 5240, 0x1234, "\x00" x 160));
snd($sock_a, $port_b, rtp(0, 1015, 5400, 0x1234, "\x00" x 160));
rcv($sock_b, $port_a, rtpm(0, 1015, 5400, 0x1234, "\x00" x 160));
snd($sock_a, $port_b, rtp(0, 1016, 5560, 0x1234, "\x00" x 160));
rcv($sock_b, $port_a, rtpm(0, 1016, 5560, 0x1234, "\x00" x 160));
snd($sock_a, $port_b, rtp(0, 1017, 5720, 0x1234, "\x00" x 160));
rcv($sock_b, $port_a, rtpm(0, 1017, 5720, 0x1234, "\x00" x 160));
snd($sock_a, $port_b, rtp(0, 1018, 5880, 0x1234, "\x00" x 160));
rcv($sock_b, $port_a, rtpm(0, 1018, 5880, 0x1234, "\x00" x 160));
snd($sock_a, $port_b, rtp(0, 1019, 6040, 0x1234, "\x00" x 160));
rcv($sock_b, $port_a, rtpm(0, 1019, 6040, 0x1234, "\x00" x 160));
snd($sock_a, $port_b, rtp(0, 1020, 6200, 0x1234, "\x00" x 160));
rcv($sock_b, $port_a, rtpm(0, 1020, 6200, 0x1234, "\x00" x 160));
snd($sock_a, $port_b, rtp(0, 1021, 6360, 0x1234, "\x00" x 160));
rcv($sock_b, $port_a, rtpm(0, 1021, 6360, 0x1234, "\x00" x 160));
snd($sock_a, $port_b, rtp(0, 1022, 6520, 0x1234, "\x00" x 160));
rcv($sock_b, $port_a, rtpm(0, 1022, 6520, 0x1234, "\x00" x 160));
snd($sock_a, $port_b, rtp(0, 1023, 6680, 0x1234, "\x00" x 160));
rcv($sock_b, $port_a, rtpm(0, 1023, 6680, 0x1234, "\x00" x 160));
snd($sock_a, $port_b, rtp(0, 1024, 6840, 0x1234, "\x00" x 160));
rcv($sock_b, $port_a, rtpm(0, 1024, 6840, 0x1234, "\x00" x 160));
snd($sock_a, $port_b, rtp(0, 1025, 7000, 0x1234, "\x00" x 160));
rcv($sock_b, $port_a, rtpm(0, 1025, 7000, 0x1234, "\x00" x 160));
snd($sock_a, $port_b, rtp(0, 1026, 7160, 0x1234, "\x00" x 160));
rcv($sock_b, $port_a, rtpm(0, 1026, 7160, 0x1234, "\x00" x 160));
snd($sock_a, $port_b, rtp(0, 1027, 7320, 0x1234, "\x00" x 160));
rcv($sock_b, $port_a, rtpm(0, 1027, 7320, 0x1234, "\x00" x 160));
snd($sock_a, $port_b, rtp(0, 1028, 7480, 0x1234, "\x00" x 160));
rcv($sock_b, $port_a, rtpm(0, 1028, 7480, 0x1234, "\x00" x 160));
snd($sock_a, $port_b, rtp(0, 1029, 7640, 0x1234, "\x00" x 160));
rcv($sock_b, $port_a, rtpm(0, 1029, 7640, 0x1234, "\x00" x 160));
snd($sock_a, $port_b, rtp(0, 1030, 7800, 0x1234, "\x00" x 160));
rcv($sock_b, $port_a, rtpm(0, 1030, 7800, 0x1234, "\x00" x 160));
snd($sock_a, $port_b, rtp(0, 1031, 7960, 0x1234, "\x00" x 160));
rcv($sock_b, $port_a, rtpm(0, 1031, 7960, 0x1234, "\x00" x 160));
snd($sock_a, $port_b, rtp(0, 1032, 8120, 0x1234, "\x00" x 160));
rcv($sock_b, $port_a, rtpm(0, 1032, 8120, 0x1234, "\x00" x 160));
snd($sock_a, $port_b, rtp(0, 1033, 8280, 0x1234, "\x00" x 160));
rcv($sock_b, $port_a, rtpm(0, 1033, 8280, 0x1234, "\x00" x 160));
snd($sock_a, $port_b, rtp(0, 1034, 8440, 0x1234, "\x00" x 160));
rcv($sock_b, $port_a, rtpm(0, 1034, 8440, 0x1234, "\x00" x 160));
snd($sock_a, $port_b, rtp(0, 1035, 8600, 0x1234, "\x00" x 160));
rcv($sock_b, $port_a, rtpm(0, 1035, 8600, 0x1234, "\x00" x 160));
snd($sock_a, $port_b, rtp(0, 1036, 8760, 0x1234, "\x00" x 160));
rcv($sock_b, $port_a, rtpm(0, 1036, 8760, 0x1234, "\x00" x 160));
snd($sock_a, $port_b, rtp(0, 1037, 8920, 0x1234, "\x00" x 160));
rcv($sock_b, $port_a, rtpm(0, 1037, 8920, 0x1234, "\x00" x 160));

snd($sock_b, $port_a, rtp(0, 2000, 4000, 0x161c, "\x00" x 160));
rcv($sock_a, $port_b, rtpm(0, 2000, 4000, 0x161c, "\x00" x 160));
snd($sock_b, $port_a, rtp(0, 2001, 4160, 0x161c, "\x00" x 160));
rcv($sock_a, $port_b, rtpm(0, 2001, 4160, 0x161c, "\x00" x 160));
snd($sock_b, $port_a, rtp(0, 2003, 4480, 0x161c, "\x00" x 160));
rcv($sock_a, $port_b, rtpm(0, 2003, 4480, 0x161c, "\x00" x 160));
snd($sock_b, $port_a, rtp(0, 2004, 4640, 0x161c, "\x00" x 160));
rcv($sock_a, $port_b, rtpm(0, 2004, 4640, 0x161c, "\x00" x 160));
snd($sock_b, $port_a, rtp(0, 2005, 4800, 0x161c, "\x00" x 160));
rcv($sock_a, $port_b, rtpm(0, 2005, 4800, 0x161c, "\x00" x 160));
snd($sock_b, $port_a, rtp(0, 2006, 4960, 0x161c, "\x00" x 160));
rcv($sock_a, $port_b, rtpm(0, 2006, 4960, 0x161c, "\x00" x 160));
snd($sock_b, $port_a, rtp(0, 2007, 5120, 0x161c, "\x00" x 160));
rcv($sock_a, $port_b, rtpm(0, 2007, 5120, 0x161c, "\x00" x 160));
snd($sock_b, $port_a, rtp(0, 2008, 5280, 0x161c, "\x00" x 160));
rcv($sock_a, $port_b, rtpm(0, 2008, 5280, 0x161c, "\x00" x 160));
snd($sock_b, $port_a, rtp(0, 2009, 5440, 0x161c, "\x00" x 160));
rcv($sock_a, $port_b, rtpm(0, 2009, 5440, 0x161c, "\x00" x 160));
snd($sock_b, $port_a, rtp(0, 2010, 5600, 0x161c, "\x00" x 160));
rcv($sock_a, $port_b, rtpm(0, 2010, 5600, 0x161c, "\x00" x 160));
snd($sock_b, $port_a, rtp(0, 2011, 5760, 0x161c, "\x00" x 160));
rcv($sock_a, $port_b, rtpm(0, 2011, 5760, 0x161c, "\x00" x 160));
snd($sock_b, $port_a, rtp(0, 2012, 5920, 0x161c, "\x00" x 160));
rcv($sock_a, $port_b, rtpm(0, 2012, 5920, 0x161c, "\x00" x 160));
snd($sock_b, $port_a, rtp(0, 2013, 6080, 0x161c, "\x00" x 160));
rcv($sock_a, $port_b, rtpm(0, 2013, 6080, 0x161c, "\x00" x 160));
snd($sock_b, $port_a, rtp(0, 2014, 6240, 0x161c, "\x00" x 160));
rcv($sock_a, $port_b, rtpm(0, 2014, 6240, 0x161c, "\x00" x 160));
snd($sock_b, $port_a, rtp(0, 2015, 6400, 0x161c, "\x00" x 160));
rcv($sock_a, $port_b, rtpm(0, 2015, 6400, 0x161c, "\x00" x 160));
snd($sock_b, $port_a, rtp(0, 2016, 6560, 0x161c, "\x00" x 160));
rcv($sock_a, $port_b, rtpm(0, 2016, 6560, 0x161c, "\x00" x 160));
snd($sock_b, $port_a, rtp(0, 2017, 6720, 0x161c, "\x00" x 160));
rcv($sock_a, $port_b, rtpm(0, 2017, 6720, 0x161c, "\x00" x 160));
snd($sock_b, $port_a, rtp(0, 2018, 6880, 0x161c, "\x00" x 160));
rcv($sock_a, $port_b, rtpm(0, 2018, 6880, 0x161c, "\x00" x 160));
snd($sock_b, $port_a, rtp(0, 2019, 7040, 0x161c, "\x00" x 160));
rcv($sock_a, $port_b, rtpm(0, 2019, 7040, 0x161c, "\x00" x 160));
snd($sock_b, $port_a, rtp(0, 2020, 7200, 0x161c, "\x00" x 160));
rcv($sock_a, $port_b, rtpm(0, 2020, 7200, 0x161c, "\x00" x 160));
snd($sock_b, $port_a, rtp(0, 2021, 7360, 0x161c, "\x00" x 160));
rcv($sock_a, $port_b, rtpm(0, 2021, 7360, 0x161c, "\x00" x 160));
snd($sock_b, $port_a, rtp(0, 2022, 7520, 0x161c, "\x00" x 160));
rcv($sock_a, $port_b, rtpm(0, 2022, 7520, 0x161c, "\x00" x 160));
snd($sock_b, $port_a, rtp(0, 2023, 7680, 0x161c, "\x00" x 160));
rcv($sock_a, $port_b, rtpm(0, 2023, 7680, 0x161c, "\x00" x 160));
snd($sock_b, $port_a, rtp(0, 2024, 7840, 0x161c, "\x00" x 160));
rcv($sock_a, $port_b, rtpm(0, 2024, 7840, 0x161c, "\x00" x 160));
snd($sock_b, $port_a, rtp(0, 2025, 8000, 0x161c, "\x00" x 160));
rcv($sock_a, $port_b, rtpm(0, 2025, 8000, 0x161c, "\x00" x 160));
snd($sock_b, $port_a, rtp(0, 2026, 8160, 0x161c, "\x00" x 160));
rcv($sock_a, $port_b, rtpm(0, 2026, 8160, 0x161c, "\x00" x 160));
snd($sock_b, $port_a, rtp(0, 2027, 8320, 0x161c, "\x00" x 160));
rcv($sock_a, $port_b, rtpm(0, 2027, 8320, 0x161c, "\x00" x 160));
snd($sock_b, $port_a, rtp(0, 2028, 8480, 0x161c, "\x00" x 160));
rcv($sock_a, $port_b, rtpm(0, 2028, 8480, 0x161c, "\x00" x 160));
snd($sock_b, $port_a, rtp(0, 2029, 8640, 0x161c, "\x00" x 160));
rcv($sock_a, $port_b, rtpm(0, 2029, 8640, 0x161c, "\x00" x 160));
snd($sock_b, $port_a, rtp(0, 2030, 8800, 0x161c, "\x00" x 160));
rcv($sock_a, $port_b, rtpm(0, 2030, 8800, 0x161c, "\x00" x 160));
snd($sock_b, $port_a, rtp(0, 2031, 8960, 0x161c, "\x00" x 160));
rcv($sock_a, $port_b, rtpm(0, 2031, 8960, 0x161c, "\x00" x 160));
snd($sock_b, $port_a, rtp(0, 2032, 9120, 0x161c, "\x00" x 160));
rcv($sock_a, $port_b, rtpm(0, 2032, 9120, 0x161c, "\x00" x 160));
snd($sock_b, $port_a, rtp(0, 2033, 9280, 0x161c, "\x00" x 160));
rcv($sock_a, $port_b, rtpm(0, 2033, 9280, 0x161c, "\x00" x 160));
snd($sock_b, $port_a, rtp(0, 2034, 9440, 0x161c, "\x00" x 160));
rcv($sock_a, $port_b, rtpm(0, 2034, 9440, 0x161c, "\x00" x 160));
snd($sock_b, $port_a, rtp(0, 2035, 9600, 0x161c, "\x00" x 160));
rcv($sock_a, $port_b, rtpm(0, 2035, 9600, 0x161c, "\x00" x 160));
snd($sock_b, $port_a, rtp(0, 2036, 9760, 0x161c, "\x00" x 160));
rcv($sock_a, $port_b, rtpm(0, 2036, 9760, 0x161c, "\x00" x 160));
snd($sock_b, $port_a, rtp(0, 2037, 9920, 0x161c, "\x00" x 160));
rcv($sock_a, $port_b, rtpm(0, 2037, 9920, 0x161c, "\x00" x 160));

# wait for RTCP

sleep(7);

rcv($sock_bx, $port_ax, qr/^
	\x81 # version 2, 1 SSRC
	\xc8 # PT=200
	\x00\x0c # length
	\x00\x00\x12\x34 # sender SSRC
	........ # NTP TS
	\x00\x00\x22\xd8 # RTP TS
	\x00\x00\x00\x25 # packet count
	\x00\x00\x18\xdc # octet count
	\x00\x00\x16\x1c # source SSRC
	\x06\x00\x00\x01 # lost count
	\x00\x00\x07\xf5 # highest seq
	.... # jitter
	.... # LSR
	.... # DLSR
	\x81 # version 2, 1 SSRC
	\xca # PT=202
	\x00\x05 # length
	\x00\x00\x12\x34 # SSRC
	\x01 # SDES CNAME
	\x0c # length
	............ # instance ID
	\x00\x00$/sx);
rcv($sock_ax, $port_bx, qr/^
	\x81 # version 2, 1 SSRC
	\xc8 # PT=200
	\x00\x0c # length
	\x00\x00\x16\x1c # sender SSRC
	........ # NTP TS
	\x00\x00\x26\xc0 # RTP TS
	\x00\x00\x00\x25 # packet count
	\x00\x00\x18\xdc # octet count
	\x00\x00\x12\x34 # source SSRC
	\x06\x00\x00\x01 # lost count
	\x00\x00\x04\x0d # highest seq
	.... # jitter
	.... # LSR
	.... # DLSR
	\x81 # version 2, 1 SSRC
	\xca # PT=202
	\x00\x05 # length
	\x00\x00\x16\x1c # SSRC
	\x01 # SDES CNAME
	\x0c # length
	............ # instance ID
	\x00\x00$/sx);

$resp = rtpe_req('delete', 'packet loss', { 'from-tag' => ft() });


done_testing();
#NGCP::Rtpengine::AutoTest::terminate('foo');
