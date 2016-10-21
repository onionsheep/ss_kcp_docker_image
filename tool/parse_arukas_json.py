#!/usr/bin/env python3

import http.client
import json
import base64
import os
import string
import sys
import http.server
import tornado.ioloop
import tornado.web


def generate_arukas_authorization_token():
    arukas_token = os.environ.get('arukas_token')
    arukas_secret = os.environ.get('arukas_secret')
    if not arukas_token or not arukas_token:
        sys.exit('env arukas_token or arukas_secret does not exist')

    auth_string = arukas_token + ':' + arukas_secret
    authorization_token = base64.b64encode(auth_string.encode('ascii')).decode()
    print('authorization_token is : {0}'.format(authorization_token))
    return authorization_token


def get_containers():
    conn = http.client.HTTPSConnection('app.arukas.io')
    headers = {
        'content-type': 'application/vnd.api+json',
        'accept': 'application/vnd.api+json',
        'authorization': 'Basic {0}'.format(generate_arukas_authorization_token()),
        'cache-control': 'no-cache'
    }

    conn.request('GET', '/api/containers', headers=headers)
    res = conn.getresponse()
    data = res.read()
    jsondata = json.loads(data.decode('utf-8'))
    containers = jsondata['data']
    return containers


def generate_ss_links():
    ss_links = []
    ssencryption = os.environ.get('ssencryption', 'aes-256-cfb')
    sspassword = os.environ.get('sspassword', '12345679')
    ssport = os.environ.get('ssport', '4000')
    containers = get_containers()
    for container in containers:
        attributes = container['attributes']
        if attributes['image_name'] == 'onionsheep/ss_kcp:latest':
            port_mappings = attributes['port_mappings'][0]
            for pm in port_mappings:
                if pm['container_port'] == int(ssport):
                    ss_string = '{0}:{1}@{2}:{3}'.format(ssencryption,
                                                         sspassword,
                                                         pm['host'],
                                                         pm['service_port'])
                    ss_base64 = base64.b64encode(
                        ss_string.encode('ascii')).decode()
                    ss_link = 'ss://{0}'.format(ss_base64)
                    ss_links.append(ss_link)
                    print(ss_link)
                    # ss://method:password@hostname:port
                    # print(pm)
    return ss_links


class SSKCPHTTPServer(http.server.SimpleHTTPRequestHandler):
    def do_POST(self):
        print(self.path)
        pass


def run(server_class=http.server.HTTPServer,
        handler_class=SSKCPHTTPServer):
    server_address = ('0.0.0.0', 80)
    httpd = server_class(server_address, handler_class)
    httpd.serve_forever()


class MainHandler(tornado.web.RequestHandler):
    def data_received(self, chunk):
        pass

    def get(self):
        print(self.path_args)
        print(self.request.host)
        self.write('Hello, world')


def main():
    generate_ss_links()
    application = tornado.web.Application([
        (r'/', MainHandler),
    ], debug=True, autoreload=False)
    application.listen(8888)
    tornado.ioloop.IOLoop.current().start()


if __name__ == '__main__':
    sys.exit(int(main() or 0))






