import pytest
from typing import Optional
from pathlib import Path
from ragger.firmware import Firmware
from ragger.backend import SpeculosBackend, LedgerCommBackend, LedgerWalletBackend
from ragger.navigator import NanoNavigator
from ragger.utils import app_path_from_app_name


# This variable is needed for Speculos only (physical tests need the application to be already installed)
# Adapt this path to your 'tests/elfs' directory
APPS_DIRECTORY = (Path(__file__).parent.parent / "elfs").resolve()

# Adapt this name part of the compiled app <name>_<device>.elf in the APPS_DIRECTORY
APP_NAME = "aelf"

BACKENDS = ["speculos", "ledgercomm", "ledgerwallet"]

DEVICES = ["nanos", "nanox", "nanosp", "all"]

FIRMWARES = [
    Firmware.NANOS,
    Firmware.NANOSP,
    Firmware.NANOX,
    Firmware.STAX,
]

def pytest_addoption(parser):
    parser.addoption("--device", choices=DEVICES, required=True)
    parser.addoption("--backend", choices=BACKENDS, default="speculos")
    parser.addoption("--display", action="store_true", default=False)
    parser.addoption("--golden_run", action="store_true", default=False)
    parser.addoption("--log_apdu_file", action="store", default=None)
    parser.addoption("--seed", action="store", default="mind palm gallery soldier flame biology lion retreat depart sponsor shove fringe inflict conduct extra ladder weapon dinner modify jeans display eternal mercy detail")


@pytest.fixture(scope="session")
def backend_name(pytestconfig):
    return pytestconfig.getoption("backend")


@pytest.fixture(scope="session")
def display(pytestconfig):
    return pytestconfig.getoption("display")


@pytest.fixture(scope="session")
def golden_run(pytestconfig):
    return pytestconfig.getoption("golden_run")


@pytest.fixture(scope="session")
def log_apdu_file(pytestconfig):
    filename = pytestconfig.getoption("log_apdu_file")
    return Path(filename).resolve() if filename is not None else None

@pytest.fixture(scope="session")
def cli_user_seed(pytestconfig):
    return pytestconfig.getoption("seed")

@pytest.fixture
def test_name(request):
    # Get the name of current pytest test
    test_name = request.node.name

    # Remove firmware suffix:
    # -  test_xxx_transaction_ok[nanox 2.0.2]
    # => test_xxx_transaction_ok
    return test_name.split("[")[0]


# Glue to call every test that depends on the firmware once for each required firmware
def pytest_generate_tests(metafunc):
    if "firmware" in metafunc.fixturenames:
        fw_list = []
        ids = []

        device = metafunc.config.getoption("device")
        backend_name = metafunc.config.getoption("backend")

        # Enable firmware for requested devices
        for fw in FIRMWARES:
            if device == fw.name or device == "all" or (device == "all_nano" and fw.is_nano):
                fw_list.append(fw)
                ids.append(fw.name)

        if len(fw_list) > 1 and backend_name != "speculos":
            raise ValueError("Invalid device parameter on this backend")

        metafunc.parametrize("firmware", fw_list, ids=ids, scope="session")



def prepare_speculos_args(firmware: Firmware, display: bool, cli_user_seed: str):
    speculos_args = []

    if display:
        speculos_args += ["--display", "qt"]

    if cli_user_seed:
        speculos_args += ["--seed", cli_user_seed]

    app_path = app_path_from_app_name(APPS_DIRECTORY, APP_NAME, firmware.device)

    return ([app_path], {"args": speculos_args})


# Depending on the "--backend" option value, a different backend is
# instantiated, and the tests will either run on Speculos or on a physical
# device depending on the backend
def create_backend(backend_name: str, firmware: Firmware, display: bool, log_apdu_file: Optional[Path], cli_user_seed: str):
    if backend_name.lower() == "ledgercomm":
        return LedgerCommBackend(firmware=firmware, interface="hid", log_apdu_file=log_apdu_file)
    elif backend_name.lower() == "ledgerwallet":
        return LedgerWalletBackend(firmware=firmware, log_apdu_file=log_apdu_file)
    elif backend_name.lower() == "speculos":
        args, kwargs = prepare_speculos_args(firmware, display, cli_user_seed)
        return SpeculosBackend(*args, firmware=firmware, log_apdu_file=log_apdu_file, **kwargs)
    else:
        raise ValueError(f"Backend '{backend_name}' is unknown. Valid backends are: {BACKENDS}")


# This fixture will return the properly configured backend, to be used in tests.
# As Speculos instantiation takes some time, this fixture scope is by default "session".
# If your tests needs to be run on independent Speculos instances (in case they affect
# settings for example), then you should change this fixture scope and choose between
# function, class, module or session.
# @pytest.fixture(scope="session")
@pytest.fixture(scope="function")
def backend(backend_name, firmware, display, log_apdu_file, cli_user_seed):
    with create_backend(backend_name, firmware, display, log_apdu_file, cli_user_seed) as b:
        yield b


@pytest.fixture
def navigator(backend, firmware, golden_run):
    if firmware.device.startswith("nano"):
        return NanoNavigator(backend, firmware, golden_run)
    else:
        raise ValueError(f"Device '{firmware.device}' is unsupported.")


@pytest.fixture(autouse=True)
def use_only_on_backend(request, backend):
    if request.node.get_closest_marker('use_on_backend'):
        current_backend = request.node.get_closest_marker('use_on_backend').args[0]
        if current_backend != backend:
            pytest.skip(f'skipped on this backend: "{current_backend}"')


def pytest_configure(config):
    config.addinivalue_line(
        "markers", "use_only_on_backend(backend): skip test if not on the specified backend",
    )
