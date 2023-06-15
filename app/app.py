#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import os
import time
import random
from flask import Flask
from prometheus_flask_exporter import PrometheusMetrics, NO_PREFIX


app = Flask(__name__, static_url_path="")
metrics = PrometheusMetrics(app, defaults_prefix=NO_PREFIX)

@app.route("/")
def index():
    return f"version: {os.getenv('VERSION', 'unknown')}"
