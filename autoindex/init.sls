include:
  - supervisor
  - nginx
  - virtualenv
  {% if not pillar['index_url'] %}- git{% endif %}

autoindex:
  user.present:
    - gid_from_name: True
  file.directory:
    - name: /srv/www/autoindex
    - user: autoindex
    - group: autoindex
    - makedirs: True
    - require:
      - user: autoindex
  virtualenv.managed:
    - name: /srv/www/autoindex
    - no_site_packages: True
    - require:
      - file: autoindex
  cmd.wait:
    - name: bin/pip install -U pip; bin/pip install -r requirements.txt
    - cwd: /srv/www/autoindex
    - require:
      - virtualenv: autoindex
    - watch:
      - file: autoindex-requirements

autoindex-requirements:
  file.managed:
    - name: /srv/www/autoindex/requirements.txt
    - source: salt://autoindex/requirements.txt
    - template: jinja
    - defaults:
      autoindex_version: 0.1
    - require:
      - file: autoindex

autoindex-public:
  file.directory:
    - name: /srv/www/autoindex/public
    - recurse:
      - user
    - user: autoindex
    - require:
      - file: autoindex
      - user: autoindex

autoindex-mirror:
  file.managed:
    - name: /srv/www/autoindex/public/mirror
    - source: salt://autoindex/mirror
    - user: autoindex
    - template: jinja
    - require:
      - file: autoindex-public
  cmd.wait:
    - name: bin/autoindex mirror -d /srv/www/autoindex/public
    - cwd: /srv/www/autoindex
    - user: autoindex
    - require:
      - cmd: autoindex-watch
    - watch:
      - file: autoindex-mirror

autoindex-log:
  file.directory:
    - name: /var/log/autoindex
    - user: autoindex
    - require:
      - user: autoindex

autoindex-watch:
  file.managed:
    - name: /etc/supervisor/conf.d/autoindex-watch.conf
    - source: salt://autoindex/watch.conf
    - template: jinja
    - require:
      - file: autoindex-log
  cmd.wait:
    - name: supervisorctl update
    - watch:
      - file: autoindex-watch
    - require:
      - cmd: autoindex

restart-watcher:
  cmd.wait:
    - name: supervisorctl restart autoindex-watch
    - watch:
      - cmd: autoindex

autoindex-server:
  file.managed:
    - name: /etc/nginx/sites-available/autoindex.conf
    - source: salt://autoindex/nginx.conf
    - template: jinja
    - require:
      - pkg: nginx
      - file: autoindex-public

autoindex-symlink:
  file.symlink:
    - name: /etc/nginx/sites-enabled/autoindex.conf
    - target: /etc/nginx/sites-available/autoindex.conf
    - require:
      - file: autoindex-server

extend:
  nginx:
    service:
      - watch:
        - file: autoindex-server
