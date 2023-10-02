r"""
A Python module for radar simulation

----------
RadarSimPy - A Radar Simulator Built with Python
Copyright (C) 2018 - PRESENT  radarsimx.com
E-mail: info@radarsimx.com
Website: https://radarsimx.com

 ____           _            ____  _          __  __
|  _ \ __ _  __| | __ _ _ __/ ___|(_)_ __ ___ \ \/ /
| |_) / _` |/ _` |/ _` | '__\___ \| | '_ ` _ \ \  /
|  _ < (_| | (_| | (_| | |   ___) | | | | | | |/  \
|_| \_\__,_|\__,_|\__,_|_|  |____/|_|_| |_| |_/_/\_\

"""

from radarsimpy.includes.radarsimc cimport RxChannel
from radarsimpy.includes.radarsimc cimport TxChannel
from radarsimpy.includes.radarsimc cimport Transmitter
from radarsimpy.includes.radarsimc cimport Target
from radarsimpy.includes.radarsimc cimport Point
from radarsimpy.includes.radarsimc cimport Mem_Copy
from radarsimpy.includes.radarsimc cimport Mem_Copy_Vec3
from radarsimpy.includes.radarsimc cimport Mem_Copy_Complex
from radarsimpy.includes.type_def cimport float_t


cdef Point[float_t] cp_Point(location, speed, rcs, phase, shape)
cdef Transmitter[float_t] cp_Transmitter(radar)
cdef TxChannel[float_t] cp_TxChannel(tx, tx_idx)
cdef RxChannel[float_t] cp_RxChannel(rx, rx_idx)
cdef Target[float_t] cp_Target(radar, target, shape)
cdef Target[float_t] cp_RCS_Target(target)
