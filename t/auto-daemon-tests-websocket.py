import asyncio
import ssl
import websockets
import sys
import unittest
import json
import uuid

# ssl_context = ssl.SSLContext(ssl.PROTOCOL_TLS_CLIENT)
# ssl_context.check_hostname = False
# ssl_context.verify_mode = ssl.CERT_NONE
# 
# async def do():
#     global args
#     uri = "wss://localhost:7171/"
#     async with websockets.connect(uri, subprotocols=['janus-protocol'], ssl=ssl_context) as websocket:
#         m = args[0]
#         args = args[1:]
#         print(f"sending {m}")
#         await websocket.send(m)
#         msg = await websocket.recv()
#         print(f"{msg}")
# 
# asyncio.get_event_loop().run_until_complete(do())


# ./rtpengine --config-file=none -t -1 -i wlp2s0 -n 2223 -c 12345 -f -L 7 -E -u 2222 --listen-https=localhost:7171 --listen-https=localhost:8181 --listen-http=localhost:9191 --https-cert=/home/dfx/cert.pem --janus-secret=YkzAwuEvgLyATjHPvckg --delete-delay=0


async def get_ws(cls, proto):
    cls._ws = await websockets.connect("ws://localhost:9191/", \
            subprotocols=[proto])

async def testIO(self, msg):
    await self._ws.send(msg)
    self._res = await self._ws.recv()

async def testIOJson(self, msg):
    await self._ws.send(json.dumps(msg))
    self._res = await self._ws.recv()
    self._res = json.loads(self._res)

async def testIJanus(self):
    self._res = await self._ws.recv()
    self._res = json.loads(self._res)
    self.assertEqual(self._res['transaction'], self._trans)
    del self._res['transaction']

async def testIOJanus(self, msg):
    trans = str(uuid.uuid4())
    msg['transaction'] = trans
    self._trans = trans
    await self._ws.send(json.dumps(msg))
    await testIJanus(self)


class TestWSEcho(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls._eventloop = asyncio.get_event_loop()
        cls._eventloop.run_until_complete(get_ws(cls, 'echo.rtpengine.com'))

    def testEcho(self):
        self._eventloop.run_until_complete(testIO(self, b'foobar'))
        self.assertEqual(self._res, b'foobar')

    def testEchoText(self):
        self._eventloop.run_until_complete(testIO(self, 'foobar'))
        self.assertEqual(self._res, b'foobar')


class TestWSCli(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls._eventloop = asyncio.get_event_loop()
        cls._eventloop.run_until_complete(get_ws(cls, 'cli.rtpengine.com'))

    def testListNumsessions(self):
        # race condition here if this runs at the same as the janus test (creates call)
        self._eventloop.run_until_complete(testIO(self, 'list numsessions'))
        self.assertEqual(self._res, \
                b'Current sessions own: 0\n' +
                b'Current sessions foreign: 0\n' +
                b'Current sessions total: 0\n' +
                b'Current transcoded media: 0\n' +
                b'Current sessions ipv4 only media: 0\n' +
                b'Current sessions ipv6 only media: 0\n' +
                b'Current sessions ip mixed  media: 0\n')



class TestWSJanus(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls._eventloop = asyncio.get_event_loop()
        cls._eventloop.run_until_complete(get_ws(cls, 'janus-protocol'))

    def testPing(self):
        self._eventloop.run_until_complete(testIOJson(self,
                { 'janus': 'ping', 'transaction': 'test123' }))
        self.assertEqual(self._res, \
                { 'janus': 'pong', 'transaction': 'test123' }
        )

    def testPingNoTS(self):
        self._eventloop.run_until_complete(testIOJson(self,
                { 'janus': 'ping' }))
        self.assertEqual(self._res,
                { 'janus': 'error', 'error':
                        { 'code': 456, 'reason': "JSON object does not contain 'transaction' key" } }
        )

    def testInfo(self):
        self._eventloop.run_until_complete(testIOJson(self,
                { 'janus': 'info', 'transaction': 'foobar' }))
        # ignore version string
        self.assertTrue('version_string' in self._res)
        del self._res['version_string']
        self.assertEqual(self._res,
                { 'janus': 'server_info',
                    'name': 'rtpengine Janus interface',
                    'plugins': {'janus.plugin.videoroom': {'name': 'rtpengine Janus videoroom'}},
                    'transaction': 'foobar' }
        )


class TestVideoroom(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls._eventloop = asyncio.get_event_loop()
        cls._eventloop.run_until_complete(get_ws(cls, 'janus-protocol'))

    def testVideoroom(self):
        self.maxDiff = None

        token = str(uuid.uuid4())

        self._eventloop.run_until_complete(testIOJanus(self,
                { 'janus': 'add_token', 'token': token,
                    'admin_secret': 'YkzAwuEvgLyATjHPvckg' }))
        self.assertEqual(self._res,
                { 'janus': 'success', 'data': {'plugins': ['janus.plugin.videoroom'] }}
        )

        # create session
        self._eventloop.run_until_complete(testIOJanus(self,
                { 'janus': 'create', 'token': token,
                    'admin_secret': 'YkzAwuEvgLyATjHPvckg' }))
        session = self._res['data']['id']
        self.assertIsInstance(session, int)
        self.assertEqual(self._res,
                { 'janus': 'success', 'data': {'id': session }}
        )

        # test keepalive
        self._eventloop.run_until_complete(testIOJanus(self,
                { 'janus': 'keepalive', 'token': token,
                    'session_id': session }))
        self.assertEqual(self._res,
                { 'janus': 'ack', 'session_id': session }
        )

        # XXX add tests for requests for invalid IDs/handles

        # attach controlling handle #1
        self._eventloop.run_until_complete(testIOJanus(self,
                { 'janus': 'attach',
                    'plugin': 'janus.plugin.videoroom',
                    'session_id': session,
                    'token': token }))
        handle_c_1 = self._res['data']['id']
        self.assertIsInstance(handle_c_1, int)
        self.assertNotEqual(handle_c_1, session)
        self.assertEqual(self._res,
                { 'janus': 'success', 'session_id': session, 'data': {'id': handle_c_1 }}
        )

        # create room
        self._eventloop.run_until_complete(testIOJanus(self,
                { 'janus': 'message',
                    'body': { 'request': 'create', 'publishers': 16 },
                    'handle_id': handle_c_1,
                    'session_id': session,
                    'token': token }))
        room = self._res['plugindata']['data']['room']
        self.assertIsInstance(room, int)
        self.assertNotEqual(room, handle_c_1)
        self.assertNotEqual(room, session)
        self.assertEqual(self._res,
                { 'janus': 'success',
                    'session_id': session,
                    'sender': handle_c_1,
                    'plugindata':
                     { 'plugin': 'janus.plugin.videoroom',
                       'data':
                        { 'videoroom': 'created',
                          'room': room,
                          'permanent': False,
                        } } })

        # attach publisher handle #1
        self._eventloop.run_until_complete(testIOJanus(self,
                { 'janus': 'attach',
                    'plugin': 'janus.plugin.videoroom',
                    'session_id': session,
                    'token': token }))
        handle_p_1 = self._res['data']['id']
        self.assertIsInstance(handle_p_1, int)
        self.assertNotEqual(handle_p_1, handle_c_1)
        self.assertNotEqual(handle_p_1, session)
        self.assertNotEqual(handle_p_1, room)
        self.assertEqual(self._res,
                { 'janus': 'success', 'session_id': session, 'data': {'id': handle_p_1 }}
        )

        # create feed for publisher #1
        self._eventloop.run_until_complete(testIOJanus(self,
                { 'janus': 'message',
                    'body': { 'request': 'join', 'ptype': 'publisher', 'room': room },
                    'handle_id': handle_p_1,
                    'session_id': session,
                    'token': token }))
        # ack is received first
        self.assertEqual(self._res,
                { 'janus': 'ack', 'session_id': session }
        )
        # followed by the joined event
        self._eventloop.run_until_complete(testIJanus(self))
        feed_1 = self._res['plugindata']['data']['id']
        self.assertIsInstance(feed_1, int)
        self.assertNotEqual(feed_1, handle_c_1)
        self.assertNotEqual(feed_1, session)
        self.assertNotEqual(feed_1, room)
        self.assertNotEqual(feed_1, handle_p_1)
        self.assertEqual(self._res,
                { 'janus': 'event',
                    'session_id': session,
                    'sender': handle_p_1,
                    'plugindata':
                     { 'plugin': 'janus.plugin.videoroom',
                       'data':
                        { 'videoroom': 'joined',
                          'room': room,
                          'id': feed_1,
                          'publishers': [],
                        } } })

        # configure publisher feed #1 w broken SDP
        self._eventloop.run_until_complete(testIOJanus(self,
                { 'janus': 'message',
                    'body': { 'request': 'configure', 'room': room, 'feed': feed_1, 'data': False,
                        'audio': True, 'video': True},
                    'jsep': {
                        'type': 'offer',
                        'sdp': 'blah',
                    },
                    'handle_id': handle_p_1,
                    'session_id': session,
                    'token': token }))
        # ack is received first
        self.assertEqual(self._res,
                { 'janus': 'ack', 'session_id': session }
        )
        # followed by the event notification
        self._eventloop.run_until_complete(testIJanus(self))
        self.assertEqual(self._res,
                { 'janus': 'error',
                    'session_id': session,
                    'sender': handle_p_1,
                    'error': {'code': 512, 'reason': 'Failed to parse SDP'},
                    'plugindata':
                     { 'plugin': 'janus.plugin.videoroom',
                       'data': {}
                       } } )

        # configure publisher feed #1
        self._eventloop.run_until_complete(testIOJanus(self,
                { 'janus': 'message',
                    'body': { 'request': 'configure', 'room': room, 'feed': feed_1, 'data': False,
                        'audio': True, 'video': True},
                    'jsep': {
                        'type': 'offer',
                        'sdp': ("v=0\r\n"
                                "o=x 123 123 IN IP4 1.1.1.1\r\n"
                                "c=IN IP4 1.1.1.1\r\n"
                                "s=foobar\r\n"
                                "t=0 0\r\n"
                                "m=audio 6000 RTP/AVP 96 8 0\r\n"
                                "a=rtpmap:96 opus/48000\r\n"
                                "a=sendonly\r\n")
                    },
                    'handle_id': handle_p_1,
                    'session_id': session,
                    'token': token }))
        # ack is received first
        self.assertEqual(self._res,
                { 'janus': 'ack', 'session_id': session }
        )
        # followed by the event notification
        self._eventloop.run_until_complete(testIJanus(self))
        sdp = self._res['jsep']['sdp']
        self.assertIsInstance(sdp, str)
        # XXX check SDP
        self.assertEqual(self._res,
                { 'janus': 'event',
                    'session_id': session,
                    'sender': handle_p_1,
                    'plugindata':
                     { 'plugin': 'janus.plugin.videoroom',
                       'data':
                        { 'videoroom': 'event',
                          'room': room,
                          'configured': 'ok',
                          'audio_codec': 'opus',
                     } },
                     'jsep':
                     {
                         'type': 'answer',
                         'sdp': sdp
                         }})

        # attach subscriber handle #1
        self._eventloop.run_until_complete(testIOJanus(self,
                { 'janus': 'attach',
                    'plugin': 'janus.plugin.videoroom',
                    'session_id': session,
                    'token': token }))
        handle_s_1 = self._res['data']['id']
        self.assertIsInstance(handle_p_1, int)
        self.assertNotEqual(handle_p_1, handle_c_1)
        self.assertNotEqual(handle_p_1, session)
        self.assertNotEqual(handle_p_1, room)
        self.assertEqual(self._res,
                { 'janus': 'success', 'session_id': session, 'data': {'id': handle_s_1 }}
        )

        # subscriber #1 joins publisher #1
        self._eventloop.run_until_complete(testIOJanus(self,
                { 'janus': 'message',
                    'body': { 'request': 'join', 'ptype': 'subscriber', 'room': room, 'feed': feed_1 },
                    'handle_id': handle_s_1,
                    'session_id': session,
                    'token': token }))
        # ack is received first
        self.assertEqual(self._res,
                { 'janus': 'ack', 'session_id': session }
        )
        # followed by the attached event
        self._eventloop.run_until_complete(testIJanus(self))
        feed_1 = self._res['plugindata']['data']['id']
        self.assertIsInstance(feed_1, int)
        self.assertNotEqual(feed_1, handle_c_1)
        self.assertNotEqual(feed_1, session)
        self.assertNotEqual(feed_1, room)
        self.assertNotEqual(feed_1, handle_p_1)
        self.assertNotEqual(feed_1, handle_s_1)
        sdp = self._res['jsep']['sdp']
        self.assertIsInstance(sdp, str)
        # XXX check SDP
        self.assertEqual(self._res,
                { 'janus': 'event',
                    'session_id': session,
                    'sender': handle_s_1,
                    'plugindata':
                     { 'plugin': 'janus.plugin.videoroom',
                       'data':
                        { 'videoroom': 'attached',
                          'room': room,
                          'id': feed_1,
                        } },
                     'jsep':
                     {
                         'type': 'offer',
                         'sdp': sdp
                         }})

        # subscriber #1 answer
        self._eventloop.run_until_complete(testIOJanus(self,
                { 'janus': 'message',
                    'body': { 'request': 'start', 'room': room, 'feed': feed_1 },
                    'jsep': {
                        'type': 'answer',
                        'sdp': ("v=0\r\n"
                                "o=x 123 123 IN IP4 1.1.1.1\r\n"
                                "c=IN IP4 1.1.1.1\r\n"
                                "s=foobar\r\n"
                                "t=0 0\r\n"
                                "m=audio 7000 RTP/AVP 96\r\n"
                                "a=rtpmap:96 opus/48000\r\n"
                                "a=recvonly\r\n")
                    },
                    'handle_id': handle_s_1,
                    'session_id': session,
                    'token': token }))
        # ack is received first
        self.assertEqual(self._res,
                { 'janus': 'ack', 'session_id': session }
        )
        # followed by the attached event
        self._eventloop.run_until_complete(testIJanus(self))
        self.assertEqual(self._res,
                { 'janus': 'event',
                    'session_id': session,
                    'sender': handle_s_1,
                    'plugindata':
                     { 'plugin': 'janus.plugin.videoroom',
                       'data':
                        { 'videoroom': 'event',
                          'started': 'ok',
                          'room': room,
                        } } })

        # attach publisher handle #2
        self._eventloop.run_until_complete(testIOJanus(self,
                { 'janus': 'attach',
                    'plugin': 'janus.plugin.videoroom',
                    'session_id': session,
                    'token': token }))
        handle_p_2 = self._res['data']['id']
        self.assertIsInstance(handle_p_2, int)
        self.assertNotEqual(handle_p_2, handle_c_1)
        self.assertNotEqual(handle_p_2, session)
        self.assertNotEqual(handle_p_2, room)
        self.assertEqual(self._res,
                { 'janus': 'success', 'session_id': session, 'data': {'id': handle_p_2 }}
        )

        # create feed for publisher #2
        self._eventloop.run_until_complete(testIOJanus(self,
                { 'janus': 'message',
                    'body': { 'request': 'join', 'ptype': 'publisher', 'room': room },
                    'handle_id': handle_p_2,
                    'session_id': session,
                    'token': token }))
        # ack is received first
        self.assertEqual(self._res,
                { 'janus': 'ack', 'session_id': session }
        )
        # followed by the joined event
        self._eventloop.run_until_complete(testIJanus(self))
        feed_2 = self._res['plugindata']['data']['id']
        self.assertIsInstance(feed_2, int)
        self.assertNotEqual(feed_2, handle_c_1)
        self.assertNotEqual(feed_2, session)
        self.assertNotEqual(feed_2, room)
        self.assertNotEqual(feed_2, handle_p_1)
        self.assertNotEqual(feed_2, handle_p_2)
        self.assertEqual(self._res,
                { 'janus': 'event',
                    'session_id': session,
                    'sender': handle_p_2,
                    'plugindata':
                     { 'plugin': 'janus.plugin.videoroom',
                       'data':
                        { 'videoroom': 'joined',
                          'room': room,
                          'id': feed_2,
                          'publishers': [
                              { 'id': feed_1 },
                            ],
                        } } })

        # configure publisher feed #1 with trickle ICE
        self._eventloop.run_until_complete(testIOJanus(self,
                { 'janus': 'message',
                    'body': { 'request': 'configure', 'room': room, 'feed': feed_2, 'data': False,
                        'audio': True, 'video': True},
                    'jsep': {
                        'type': 'offer',
                        'sdp': ("v=0\r\n"
                                "o=x 123 123 IN IP4 1.1.1.1\r\n"
                                "c=IN IP4 0.0.0.0\r\n"
                                "s=foobar\r\n"
                                "t=0 0\r\n"
                                "m=audio 9 RTP/AVP 8 0\r\n"
                                "a=mid:audio\r\n"
                                "a=rtpmap:96 opus/48000\r\n"
                                "a=ice-ufrag:62lL\r\n"
                                "a=ice-pwd:WD1pLdamJOWH2WuEBb0vjyZr\r\n"
                                "a=ice-options:trickle\r\n"
                                "a=rtcp-mux\r\n"
                                "a=sendonly\r\n")
                    },
                    'handle_id': handle_p_2,
                    'session_id': session,
                    'token': token }))
        # ack is received first
        self.assertEqual(self._res,
                { 'janus': 'ack', 'session_id': session }
        )
        # followed by the event notification
        self._eventloop.run_until_complete(testIJanus(self))
        sdp = self._res['jsep']['sdp']
        self.assertIsInstance(sdp, str)
        # XXX check SDP
        self.assertEqual(self._res,
                { 'janus': 'event',
                    'session_id': session,
                    'sender': handle_p_2,
                    'plugindata':
                     { 'plugin': 'janus.plugin.videoroom',
                       'data':
                        { 'videoroom': 'event',
                          'room': room,
                          'configured': 'ok',
                          'audio_codec': 'PCMA',
                     } },
                     'jsep':
                     {
                         'type': 'answer',
                         'sdp': sdp
                         }})

        # trickle update
        self._eventloop.run_until_complete(testIOJanus(self,
                { 'janus': 'trickle',
                    'candidate': {
                        'candidate': 'candidate:3279615273 1 udp 2113937151 2.2.2.2 46951 typ host generation 0 ufrag 62lL network-cost 999',
                        'sdpMid': 'audio',
                    },
                    'handle_id': handle_p_2,
                    'session_id': session,
                    'token': token }))
        self.assertEqual(self._res,
                { 'janus': 'ack', 'session_id': session }
        )

        # destroy room
        self._eventloop.run_until_complete(testIOJanus(self,
                { 'janus': 'message',
                    'body': { 'request': 'destroy', 'room': room },
                    'handle_id': handle_c_1,
                    'session_id': session,
                    'token': token }))
        self.assertNotEqual(room, handle_c_1)
        self.assertNotEqual(room, session)
        self.assertEqual(self._res,
                { 'janus': 'success',
                    'session_id': session,
                    'sender': handle_c_1,
                    'plugindata':
                     { 'plugin': 'janus.plugin.videoroom',
                       'data':
                        { 'videoroom': 'destroyed',
                          'room': room,
                          'permanent': False,
                        } } })



if __name__ == '__main__':
    unittest.main()
