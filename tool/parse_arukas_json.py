#!/usr/bin/env python3

import http.client
import json
import base64
import os
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
        'authorization': 'Basic {0}'.format(
            generate_arukas_authorization_token()),
        'cache-control': 'no-cache'
    }

    conn.request('GET', '/api/containers', headers=headers)
    res = conn.getresponse()
    data = res.read()
    jsondata = json.loads(data.decode('utf-8'))

    containers = jsondata['data']
    return containers


def generate_ss_links(containers=get_containers()):
    ss_links = []
    ssencryption = os.environ.get('ssencryption', 'aes-256-cfb')
    sspassword = os.environ.get('sspassword', '12345679')
    ssport = os.environ.get('ssport', '4000')
    for container in containers:
        attributes = container['attributes']
        if attributes['image_name'].startwith('onionsheep/ss_kcp'):
            port_mappings_arr = attributes['port_mappings']
            if not port_mappings_arr:
                continue
            port_mappings = attributes['port_mappings'][0]
            for pm in port_mappings:
                if pm['container_port'] == int(ssport):
                    ss_link, ss_string = compute_ss_link(ssencryption,
                                                         sspassword,
                                                         pm['host'],
                                                         pm['service_port'])
                    ss_link_info = {'ss_link': ss_link,
                                    'ss_string': ss_string,
                                    'container': attributes['arukas_domain']
                                    }
                    ss_links.append(ss_link_info)
                    print(ss_link_info)
                    # ss://method:password@hostname:port
                    # print(pm)
    return ss_links


def compute_ss_link(method, password, host, port):
    ss_string = '{0}:{1}@{2}:{3}'.format(method, password, host, port)
    ss_base64 = base64.b64encode(ss_string.encode('ascii')).decode()
    ss_link = 'ss://{0}'.format(ss_base64)
    return ss_link, ss_string


def filter_container_by_name(containers, container_name):
    for container in containers:
        if container["attributes"]["arukas_domain"].find(container_name) >= 0:
            yield container


class MainHandler(tornado.web.RequestHandler):
    def data_received(self, chunk):
        pass

    def get(self):
        print(self.path_args)
        print(self.request.host)
        containers = get_containers()
        container_name = os.environ.get('arukas_domain')
        if container_name:
            containers = filter_container_by_name(containers, container_name)
        self.write(json.dumps(generate_ss_links(containers)))
        self.set_header("Content-Type", "application/json; charset=utf-8")


def main():
    arukas_token = os.environ.get('arukas_token')
    arukas_secret = os.environ.get('arukas_secret')
    if not arukas_token or not arukas_secret:
        print("arukas_token and arukas_secret is needed by web service")
        sys.exit(1)
    generate_ss_links()
    settings = {
        'static_path': os.path.join(os.path.dirname(__file__), 'static'),
        # 'static_path': '/root/ssserver/tool/static',
        'cookie_secret': '__TODO:_GENERATE_YOUR_OWN_RANDOM_VALUE_HERE__',
        # 'login_url': '/login',
        'xsrf_cookies': True,
        'debug': True,
        # 'autoreload': True,
        'static_hash_cache': False,
        'serve_traceback': True,
    }
    application = tornado.web.Application([
        (r'/', MainHandler),
        (r'/(apple-touch-icon\.png)',
         tornado.web.StaticFileHandler,
         dict(path=settings['static_path']))
    ], **settings)
    application.listen(8888)
    tornado.ioloop.IOLoop.current().start()


if __name__ == '__main__':
    sys.exit(int(main() or 0))
