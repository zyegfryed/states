Postgresql
==========

Installs and configures a postgresql server. Include ``postgresql`` on a
minion.

Optionally you can add `WAL-E`_ for continuous archiving to your S3 account.
To do so, include ``postgresql.wale`` and set some pillar data::

    postgresql:
      env:
        AWS_SECRET_ACCESS_KEY: <secret here>
        AWS_ACCESS_KEY_ID: <access key here>
        WALE_S3_PREFIX: s3://some-bucket/directory/or/whatever

.. _WAL-E: https://github.com/heroku/WAL-E/
