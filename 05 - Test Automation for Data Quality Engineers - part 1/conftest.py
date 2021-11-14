import pytest


@pytest.fixture(scope="session")
def rp_logger(request):
    import logging
    # Import Report Portal logger and handler to the test module.
    from pytest_reportportal import RPLogger, RPLogHandler
    # Setting up a logging.
    logging.setLoggerClass(RPLogger)
    logger = logging.getLogger(__name__)
    logger.setLevel(logging.DEBUG)
    # Create handler for Report Portal.
    rp_handler = RPLogHandler(request.node.config.py_test_service)
    # Set INFO level for Report Portal handler.
    rp_handler.setLevel(logging.INFO)
    return logger
