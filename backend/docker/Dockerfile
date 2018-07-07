FROM shkreza/dockerbase-ubuntu-python3

WORKDIR /lockserver

COPY . .

RUN pip3 install -r requirements.txt

EXPOSE 443

ENTRYPOINT ["python3", "server/main.py"]