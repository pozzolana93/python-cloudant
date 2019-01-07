ARG PYTHON_VERSION
FROM python:$PYTHON_VERSION
ARG TEST_SUITE
WORKDIR /code
COPY . /code
RUN if [ "$TEST_SUITE" = "simplejson" ]; then 'pip install simplejson'; else echo; fi \
  && pip install -r requirements.txt \
  && pip install -r test-requirements.txt \
  && pylint ./src/cloudant
VOLUME /code/output
#ENTRYPOINT ["nosetests"]
#CMD ["-A 'not db or (db is "cloudant" or "cloudant" in db)' -w ./tests/unit --with-xunit"]
#CMD pylint ./src/cloudant && nosetests -A not db or (db is "cloudant" or "cloudant" in db)' -w ./tests/unit --with-xunit
CMD ["sh", "-c", "nosetests -A 'not db or (db is \"cloudant\" or \"cloudant\" in db)' -w ./tests/unit --with-xunit"]
