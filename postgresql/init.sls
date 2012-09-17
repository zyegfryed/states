include:
  - sysctl

postgresql:
  pkg:
    - installed
  file.managed:
    - name: /etc/postgresql/9.1/main/postgresql.conf
    - source: salt://postgresql/postgresql.conf
    - template: jinja
    - user: postgres
    - group: postgres
    - defaults:
      shared_buffers: 128MB
      work_mem: 16MB
      maintenance_work_mem: 16MB
      effective_cache_size: 256MB
    - require:
      - pkg: postgresql
  service.running:
    - enable: True
    - watch:
      - file: postgresql
      - file: postgresql-recovery

postgresql-recovery:
  file.managed:
    - name: /etc/postgresql/9.1/main/recovery.conf
    - source: salt://postgresql/recovery.conf
    - template: jinja
    - user: postgres
    - group: postgres
    - defaults:
      archivedir: {{ pillar['archivedir']|default('/mnt/server/archivedir') }}
    - require:
      - pkg: postgresql

postgresql-archivedir:
  file.managed:
    - name: {{ pillar['archivedir']|default('/mnt/server/archivedir') }}
    - user: postgres
    - group: postgres
    - mode: 750
    - makedirs: True
    - recurse:
      - user
      - group
