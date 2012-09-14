znc:
  user:
    - present
    - gid_from_name: True
  pkg:
    - installed
    - require:
      - user: znc
  file.managed:
    - name: /etc/znc/configs/znc.conf
    - source: salt://znc/znc.conf
    - template: jinja
    - user: znc
    - group: znc
    - require:
      - file: znc-configs-dir
  service:
    - running
    - watch:
      - file: znc-init
    - require:
      - pkg: znc
      - file: znc
      - cmd: znc-cert

znc-dir:
  file.directory:
    - name: /etc/znc
    - user: znc
    - group: znc

znc-configs-dir:
  file.directory:
    - name: /etc/znc/configs
    - user: znc
    - group: znc
    - require:
      - file: znc-dir

{% if pillar['znc']['cert'] %}
znc-cert:
  file.managed:
    - name: /etc/znc/znc.pem
    - template: jinja
    - source: salt://znc/znc.pem
    - user: znc
    - group: znc
    - require:
      - file: znc-dir
{% else %}
znc-cert:
  cmd.run:
    - name: znc -d /etc/znc -p
    - user: znc
    - cwd: /etc/znc
    - unless: test -f /etc/znc/znc.pem
    - require:
      - file: znc-dir
{% endif %}

znc-init:
  file.managed:
    - name: /etc/init/znc.conf
    - source: salt://znc/upstart.conf
    - template: jinja
    - require:
      - file: znc-initd

znc-initd:
  file.symlink:
    - name: /etc/init.d/znc
    - target: /lib/init/upstart-job
