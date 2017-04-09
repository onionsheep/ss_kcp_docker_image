#!/usr/bin/env python3

import base64
import json
import sys
import socket

import os
import tornado
from http import client as httpclient
from tornado import ioloop
from tornado import web


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
    conn = httpclient.HTTPSConnection('app.arukas.io')
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

    containers_attributes = [
        container.get('attributes') for container in containers if container.get('attributes')
    ]

    image_exist_filtered_containers_attributes = [
        attributes for attributes in containers_attributes if 'image_name' in attributes
    ]

    image_name_filtered_containers_attributes = [
        attributes for attributes in image_exist_filtered_containers_attributes if
        'onionsheep/ss_kcp' in attributes['image_name']
    ]

    port_mappings_exist_filtered_containers_attributes = [
        attributes for attributes in image_name_filtered_containers_attributes if
        'port_mappings' in attributes
    ]

    for attributes in port_mappings_exist_filtered_containers_attributes:
        port_mappings = attributes['port_mappings'][0]
        arukas_domain = attributes['arukas_domain']
        for pm in port_mappings:
            if pm['container_port'] != int(ssport):
                continue
            ss_host = pm['host']
            ss_ip = socket.gethostbyname(ss_host)
            ss_service_port = pm['service_port']
            ss_link, ss_string = compute_ss_link(ssencryption,
                                                 sspassword,
                                                 ss_host,
                                                 ss_service_port)
            ss_ip_link, ss_ip_string = compute_ss_link(ssencryption,
                                                 sspassword,
                                                 ss_ip,
                                                 ss_service_port)
            ss_link_info = {'ss_host_link': ss_link,
                            'ss_host_string': ss_string,
                            'ss_ip_link': ss_ip_link,
                            'ss_ip_string': ss_ip_string,
                            'container': arukas_domain
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
