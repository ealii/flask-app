FROM python:alpine

COPY ./requirements.txt .
RUN pip install -r requirements.txt

ARG VERSION
ENV VERSION=${VERSION:-unknown}
COPY . .

CMD ["flask", "run"]