"""
A Python module for radar simulation

---

- Copyright (C) 2018 - PRESENT  radarsimx.com
- E-mail: info@radarsimx.com
- Website: https://radarsimx.com

::

    ██████╗  █████╗ ██████╗  █████╗ ██████╗ ███████╗██╗███╗   ███╗██╗  ██╗
    ██╔══██╗██╔══██╗██╔══██╗██╔══██╗██╔══██╗██╔════╝██║████╗ ████║╚██╗██╔╝
    ██████╔╝███████║██║  ██║███████║██████╔╝███████╗██║██╔████╔██║ ╚███╔╝ 
    ██╔══██╗██╔══██║██║  ██║██╔══██║██╔══██╗╚════██║██║██║╚██╔╝██║ ██╔██╗ 
    ██║  ██║██║  ██║██████╔╝██║  ██║██║  ██║███████║██║██║ ╚═╝ ██║██╔╝ ██╗
    ╚═╝  ╚═╝╚═╝  ╚═╝╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝╚═╝     ╚═╝╚═╝  ╚═╝

"""

import scipy.constants as const
import numpy as np
import numpy.testing as npt

from radarsimpy import Radar
from .test_transmitter import cw_tx, fmcw_tx, tdm_fmcw_tx, pmcw_tx
from .test_receiver import cw_rx, fmcw_rx, tdm_fmcw_rx, pmcw_rx


def cw_radar():
    """_summary_

    :return: _description_
    :rtype: _type_
    """
    return Radar(transmitter=cw_tx(), receiver=cw_rx())


def test_cw_radar():
    """_summary_
    """
    cw = cw_radar()

    assert cw.sample_prop["samples_per_pulse"] == 10 * 20
    assert cw.array_prop["size"] == 1
    assert np.array_equal(cw.array_prop["virtual_array"], np.array([[0, 0, 0]]))


def fmcw_radar():
    """_summary_

    :return: _description_
    :rtype: _type_
    """
    return Radar(transmitter=fmcw_tx(), receiver=fmcw_rx(), time=[0, 1])


def test_fmcw_radar():
    """_summary_
    """
    fmcw = fmcw_radar()

    assert fmcw.sample_prop["samples_per_pulse"] == 80e-6 * 2e6
    assert fmcw.array_prop["size"] == 1
    assert np.array_equal(fmcw.array_prop["virtual_array"], np.array([[0, 0, 0]]))


def tdm_fmcw_radar():
    """_summary_

    :return: _description_
    :rtype: _type_
    """
    return Radar(transmitter=tdm_fmcw_tx(), receiver=tdm_fmcw_rx())


def test_tdm_fmcw_radar():
    """_summary_
    """
    half_wavelength = const.c / 24.125e9 / 2
    tdm = tdm_fmcw_radar()

    assert tdm.sample_prop["samples_per_pulse"] == 80e-6 * 2e6
    assert tdm.array_prop["size"] == 16
    npt.assert_almost_equal(
        tdm.array_prop["virtual_array"],
        np.array(
            [
                [0, -8 * half_wavelength, 0],
                [0, -7 * half_wavelength, 0],
                [0, -6 * half_wavelength, 0],
                [0, -5 * half_wavelength, 0],
                [0, -4 * half_wavelength, 0],
                [0, -3 * half_wavelength, 0],
                [0, -2 * half_wavelength, 0],
                [0, -1 * half_wavelength, 0],
                [0, 0 * half_wavelength, 0],
                [0, 1 * half_wavelength, 0],
                [0, 2 * half_wavelength, 0],
                [0, 3 * half_wavelength, 0],
                [0, 4 * half_wavelength, 0],
                [0, 5 * half_wavelength, 0],
                [0, 6 * half_wavelength, 0],
                [0, 7 * half_wavelength, 0],
            ]
        ),
    )


def pmcw_radar():
    """_summary_

    :return: _description_
    :rtype: _type_
    """
    code1 = np.array(
        [
            1,
            1,
            -1,
            -1,
            -1,
            -1,
            1,
            1,
            1,
            1,
            -1,
            1,
            -1,
            1,
            -1,
            1,
            1,
            1,
            -1,
            1,
            1,
            -1,
            1,
            -1,
            1,
            -1,
            -1,
            1,
            -1,
            -1,
            1,
            1,
            1,
            1,
            -1,
            1,
            -1,
            1,
            1,
            1,
            -1,
            -1,
            1,
            -1,
            1,
            -1,
            1,
            -1,
            -1,
            1,
            1,
            1,
            1,
            1,
            -1,
            -1,
            -1,
            -1,
            -1,
            1,
            -1,
            1,
            1,
            -1,
            1,
            -1,
            -1,
            1,
            -1,
            1,
            -1,
            -1,
            1,
            1,
            1,
            -1,
            -1,
            -1,
            -1,
            -1,
            1,
            -1,
            1,
            1,
            1,
            1,
            -1,
            1,
            -1,
            -1,
            -1,
            -1,
            1,
            1,
            1,
            -1,
            1,
            1,
            -1,
            -1,
            1,
            -1,
            -1,
            1,
            1,
            1,
            1,
            -1,
            1,
            1,
            1,
            1,
            -1,
            1,
            -1,
            -1,
            -1,
            -1,
            -1,
            1,
            1,
            1,
            -1,
            1,
            1,
            -1,
            -1,
            -1,
            -1,
            -1,
            -1,
            -1,
            1,
            -1,
            -1,
            -1,
            1,
            1,
            -1,
            1,
            -1,
            -1,
            -1,
            1,
            1,
            -1,
            1,
            1,
            1,
            -1,
            1,
            1,
            1,
            1,
            1,
            -1,
            -1,
            1,
            1,
            1,
            1,
            1,
            1,
            -1,
            1,
            -1,
            -1,
            -1,
            1,
            1,
            -1,
            1,
            1,
            -1,
            -1,
            1,
            -1,
            -1,
            1,
            -1,
            -1,
            1,
            1,
            1,
            -1,
            -1,
            -1,
            1,
            -1,
            -1,
            1,
            -1,
            -1,
            1,
            1,
            -1,
            1,
            1,
            1,
            1,
            -1,
            -1,
            -1,
            -1,
            1,
            -1,
            -1,
            -1,
            -1,
            1,
            -1,
            -1,
            -1,
            -1,
            1,
            -1,
            1,
            -1,
            -1,
            -1,
            1,
            1,
            1,
            -1,
            1,
            1,
            1,
            -1,
            1,
            -1,
            1,
            1,
            1,
            -1,
            -1,
            1,
            1,
            1,
            -1,
            -1,
            1,
            -1,
            -1,
            1,
            -1,
            1,
            1,
            1,
            1,
            1,
            -1,
            -1,
            -1,
            1,
            1,
        ]
    )
    code2 = np.array(
        [
            1,
            -1,
            1,
            1,
            -1,
            -1,
            -1,
            -1,
            1,
            1,
            1,
            -1,
            1,
            -1,
            -1,
            -1,
            -1,
            1,
            -1,
            -1,
            1,
            -1,
            1,
            -1,
            -1,
            -1,
            -1,
            1,
            -1,
            -1,
            1,
            -1,
            -1,
            -1,
            -1,
            1,
            1,
            1,
            1,
            -1,
            -1,
            -1,
            -1,
            1,
            1,
            -1,
            1,
            1,
            -1,
            1,
            -1,
            -1,
            -1,
            1,
            1,
            -1,
            1,
            -1,
            1,
            -1,
            -1,
            -1,
            1,
            -1,
            1,
            1,
            -1,
            1,
            -1,
            -1,
            -1,
            1,
            1,
            1,
            -1,
            -1,
            -1,
            -1,
            1,
            1,
            -1,
            1,
            -1,
            1,
            1,
            1,
            -1,
            1,
            -1,
            -1,
            1,
            -1,
            -1,
            -1,
            -1,
            -1,
            1,
            1,
            1,
            1,
            -1,
            -1,
            1,
            -1,
            -1,
            -1,
            1,
            -1,
            1,
            -1,
            1,
            -1,
            1,
            1,
            -1,
            1,
            1,
            -1,
            1,
            -1,
            1,
            1,
            -1,
            1,
            -1,
            1,
            1,
            1,
            -1,
            -1,
            1,
            1,
            -1,
            -1,
            -1,
            -1,
            1,
            -1,
            -1,
            -1,
            -1,
            1,
            1,
            -1,
            -1,
            1,
            -1,
            -1,
            -1,
            -1,
            1,
            -1,
            1,
            -1,
            -1,
            1,
            1,
            1,
            -1,
            1,
            1,
            -1,
            1,
            1,
            1,
            -1,
            -1,
            -1,
            -1,
            -1,
            -1,
            -1,
            -1,
            1,
            -1,
            -1,
            1,
            -1,
            -1,
            1,
            1,
            -1,
            -1,
            1,
            1,
            -1,
            1,
            -1,
            1,
            -1,
            -1,
            -1,
            -1,
            1,
            1,
            -1,
            -1,
            -1,
            1,
            1,
            1,
            -1,
            1,
            -1,
            -1,
            -1,
            1,
            -1,
            -1,
            1,
            1,
            1,
            -1,
            1,
            1,
            1,
            -1,
            -1,
            -1,
            -1,
            -1,
            -1,
            1,
            -1,
            1,
            1,
            1,
            1,
            1,
            -1,
            -1,
            1,
            -1,
            1,
            -1,
            -1,
            -1,
            1,
            1,
            -1,
            -1,
            -1,
            -1,
            -1,
            1,
            1,
            -1,
            1,
            1,
            -1,
            1,
            1,
            1,
            -1,
            -1,
        ]
    )
    return Radar(transmitter=pmcw_tx(code1, code2), receiver=pmcw_rx())


def test_pmcw_radar():
    """_summary_
    """
    pmcw = pmcw_radar()

    assert pmcw.sample_prop["samples_per_pulse"] == 2.1e-6 * 250e6
    assert pmcw.array_prop["size"] == 2
    assert np.array_equal(pmcw.array_prop["virtual_array"], np.array([[0, 0, 0], [0, 0, 0]]))
