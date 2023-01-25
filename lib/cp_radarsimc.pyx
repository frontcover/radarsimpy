# distutils: language = c++

# ----------
# RadarSimPy - A Radar Simulator Built with Python
# Copyright (C) 2018 - PRESENT  Zhengyu Peng
# E-mail: zpeng.me@gmail.com
# Website: https://zpeng.me

# `                      `
# -:.                  -#:
# -//:.              -###:
# -////:.          -#####:
# -/:.://:.      -###++##:
# ..   `://:-  -###+. :##:
#        `:/+####+.   :##:
# .::::::::/+###.     :##:
# .////-----+##:    `:###:
#  `-//:.   :##:  `:###/.
#    `-//:. :##:`:###/.
#      `-//:+######/.
#        `-/+####/.
#          `+##+.
#           :##:
#           :##:
#           :##:
#           :##:
#           :##:
#            .+:


import meshio

from radarsimpy.includes.zpvector cimport Vec3
from radarsimpy.includes.type_def cimport int_t
from radarsimpy.includes.type_def cimport vector

from libcpp.complex cimport complex as cpp_complex
from libcpp cimport bool

import numpy as np

cimport cython
cimport numpy as np

np_float = np.float32

@cython.cdivision(True)
@cython.boundscheck(False)
@cython.wraparound(False)
cdef Point[float_t] cp_Point(location,
                             speed,
                             rcs,
                             phase,
                             shape):
    """
    cp_Point(location, speed, rcs, phase, shape)

    Creat Point object in Cython

    :param list location:
        Target's location (m), [x, y, z]

        *Note*: Target's parameters can be specified with
        ``Radar.timestamp`` to customize the time varying property.
        Example: ``location=(1e-3*np.sin(2*np.pi*1*radar.timestamp), 0, 0)``
    :param list speed:
        Target's velocity (m/s), [x, y, z]
    :param float rcs:
        Target's RCS (dBsm)

        *Note*: Target's RCS can be specified with
        ``Radar.timestamp`` to customize the time varying property.
    :param float phase:
        Target's phase (deg)

        *Note*: Target's phase can be specified with
        ``Radar.timestamp`` to customize the time varying property.
    :param tuple shape:
        Shape of the time matrix

    :return: C++ object of a point target
    :rtype: Point
    """
    cdef vector[Vec3[float_t]] loc_vect
    cdef vector[float_t] rcs_vect
    cdef vector[float_t] phs_vect

    cdef float_t[:, :, :] loc_x
    cdef float_t[:, :, :] loc_y
    cdef float_t[:, :, :] loc_z

    cdef float_t[:, :, :] rcs_mem
    cdef float_t[:, :, :] phs_mem

    # check if there are any time varying parameters
    if np.size(location[0]) > 1 or \
            np.size(location[1]) > 1 or \
            np.size(location[2]) > 1 or \
            np.size(rcs) > 1 or \
            np.size(phase) > 1:

        if np.size(location[0]) > 1:
            loc_x = location[0].astype(np_float)
        else:
            loc_x = np.full(shape, location[0], dtype=np_float)

        if np.size(location[1]) > 1:
            loc_y = location[1].astype(np_float)
        else:
            loc_y = np.full(shape, location[1], dtype=np_float)

        if np.size(location[2]) > 1:
            loc_z = location[2].astype(np_float)
        else:
            loc_z = np.full(shape, location[2], dtype=np_float)

        if np.size(rcs) > 1:
            rcs_mem = rcs.astype(np_float)
        else:
            rcs_mem = np.full(shape, rcs, dtype=np_float)

        if np.size(phase) > 1:
            phs_mem = np.radians(phase).astype(np_float)
        else:
            phs_mem = np.full(shape, np.radians(phase), dtype=np_float)

        Mem_Copy(&rcs_mem[0,0,0], <int_t>(shape[0]*shape[1]*shape[2]), rcs_vect)
        Mem_Copy(&phs_mem[0,0,0], <int_t>(shape[0]*shape[1]*shape[2]), phs_vect)
        Mem_Copy_Vec3(&loc_x[0,0,0], &loc_y[0,0,0], &loc_z[0,0,0], <int_t>(shape[0]*shape[1]*shape[2]), loc_vect)
                    
    else:
        loc_vect.push_back(Vec3[float_t](
            <float_t> location[0],
            <float_t> location[1],
            <float_t> location[2]
        ))
        rcs_vect.push_back(<float_t> rcs)
        phs_vect.push_back(<float_t> np.radians(phase))
    
    return Point[float_t](
        loc_vect,
        Vec3[float_t](
            <float_t> speed[0],
            <float_t> speed[1],
            <float_t> speed[2]
        ),
        rcs_vect,
        phs_vect
    )


@cython.cdivision(True)
@cython.boundscheck(False)
@cython.wraparound(False)
cdef Transmitter[float_t] cp_Transmitter(radar):
    """
    cp_Transmitter(radar)

    Creat Transmitter object in Cython

    :param Radar radar:
        Radar object

    :return: C++ object of a radar transmitter
    :rtype: Transmitter
    """
    cdef int_t frames = radar.frames
    cdef int_t channles = radar.channel_size
    cdef int_t pulses = radar.transmitter.pulses
    cdef int_t samples = radar.samples_per_pulse

    cdef vector[double] t_frame_vect
    cdef vector[double] f_vect
    cdef vector[double] t_vect
    cdef vector[double] f_offset_vect
    cdef vector[double] t_pstart_vect
    cdef vector[cpp_complex[double]] pn_vect
    
    # frame time offset
    cdef double[:] t_frame_mem
    if frames > 1:
        t_frame_mem = radar.t_offset.astype(np.float64)
        Mem_Copy(&t_frame_mem[0], frames, t_frame_vect)
    else:
        t_frame_vect.push_back(<double> (radar.t_offset))

    # frequency
    cdef double[:] f_mem = radar.f.astype(np.float64)
    Mem_Copy(&f_mem[0], <int_t>(len(radar.f)), f_vect)

    # time
    cdef double[:] t_mem = radar.t.astype(np.float64)
    Mem_Copy(&t_mem[0], <int_t>(len(radar.t)), t_vect)

    # frequency offset per pulse
    cdef double[:] f_offset_mem = radar.transmitter.f_offset.astype(np.float64)
    Mem_Copy(&f_offset_mem[0], <int_t>(len(radar.transmitter.f_offset)), f_offset_vect)

    # pulse start time
    cdef double[:] t_pstart_mem = radar.transmitter.pulse_start_time.astype(np.float64)
    Mem_Copy(&t_pstart_mem[0], <int_t>(len(radar.transmitter.pulse_start_time)), t_pstart_vect)

    # phase noise
    cdef double[:, :, :] pn_real_mem
    cdef double[:, :, :] pn_imag_mem
    if radar.phase_noise is not None:
        pn_real_mem = np.real(radar.phase_noise).astype(np.float64)
        pn_imag_mem = np.imag(radar.phase_noise).astype(np.float64)
        Mem_Copy_Complex(&pn_real_mem[0,0,0], &pn_imag_mem[0,0,0], <int_t>(frames*channles*pulses*samples), pn_vect)

    return Transmitter[float_t](
        f_vect,
        f_offset_vect,
        t_vect,
        <float_t> radar.transmitter.tx_power,
        t_pstart_vect,
        t_frame_vect,
        pn_vect
    )


@cython.cdivision(True)
@cython.boundscheck(False)
@cython.wraparound(False)
cdef TxChannel[float_t] cp_TxChannel(tx,
                                     tx_idx):
    """
    TxChannel(tx, tx_idx)

    Creat TxChannel object in Cython

    :param Transmitter tx:
        Radar transmitter
    :param int tx_idx:
        Tx channel index

    :return: C++ object of a transmitter channel
    :rtype: TxChannel
    """
    cdef int_t pulses = tx.pulses

    cdef vector[float_t] az_ang_vect, az_ptn_vect
    cdef vector[float_t] el_ang_vect, el_ptn_vect

    cdef float_t[:] az_ang_mem, az_ptn_mem
    cdef float_t[:] el_ang_mem, el_ptn_mem

    cdef vector[cpp_complex[float_t]] pulse_mod_vect

    cdef bool mod_enabled
    cdef vector[cpp_complex[float_t]] mod_var_vect
    cdef vector[float_t] mod_t_vect

    # azimuth pattern
    az_ang_mem = np.radians(np.array(tx.az_angles[tx_idx])).astype(np_float)
    az_ptn_mem = np.array(tx.az_patterns[tx_idx]).astype(np_float)

    Mem_Copy(&az_ang_mem[0], <int_t>(len(tx.az_angles[tx_idx])), az_ang_vect)
    Mem_Copy(&az_ptn_mem[0], <int_t>(len(tx.az_patterns[tx_idx])), az_ptn_vect)

    # elevation pattern
    el_ang_mem = np.radians(np.flip(90-tx.el_angles[tx_idx])).astype(np_float)
    el_ptn_mem = np.flip(tx.el_patterns[tx_idx]).astype(np_float)

    Mem_Copy(&el_ang_mem[0], <int_t>(len(tx.el_angles[tx_idx])), el_ang_vect)
    Mem_Copy(&el_ptn_mem[0], <int_t>(len(tx.el_patterns[tx_idx])), el_ptn_vect)

    # pulse modulation
    cdef float_t[:] pulse_real_mem = np.real(tx.pulse_mod[tx_idx]).astype(np_float)
    cdef float_t[:] pulse_imag_mem = np.imag(tx.pulse_mod[tx_idx]).astype(np_float)
    Mem_Copy_Complex(&pulse_real_mem[0], &pulse_imag_mem[0], <int_t>(pulses), pulse_mod_vect)

    # waveform modulation
    mod_enabled = tx.waveform_mod[tx_idx]['enabled']

    cdef float_t[:] mod_real_mem, mod_imag_mem
    cdef float_t[:] mod_t_mem
    if mod_enabled:
        mod_real_mem = np.real(tx.waveform_mod[tx_idx]['var']).astype(np_float)
        mod_imag_mem = np.imag(tx.waveform_mod[tx_idx]['var']).astype(np_float)
        mod_t_mem = tx.waveform_mod[tx_idx]['t'].astype(np_float)

        Mem_Copy_Complex(&mod_real_mem[0], &mod_imag_mem[0], <int_t>(len(tx.waveform_mod[tx_idx]['var'])), mod_var_vect)
        Mem_Copy(&mod_t_mem[0], <int_t>(len(tx.waveform_mod[tx_idx]['t'])), mod_t_vect)

    return TxChannel[float_t](
        Vec3[float_t](
            <float_t> tx.locations[tx_idx, 0],
            <float_t> tx.locations[tx_idx, 1],
            <float_t> tx.locations[tx_idx, 2]
        ),
        Vec3[float_t](
            <float_t> tx.polarization[tx_idx, 0],
            <float_t> tx.polarization[tx_idx, 1],
            <float_t> tx.polarization[tx_idx, 2]
        ),
        az_ang_vect,
        az_ptn_vect,
        el_ang_vect,
        el_ptn_vect,
        <float_t> tx.antenna_gains[tx_idx],
        mod_t_vect,
        mod_var_vect,
        pulse_mod_vect,
        <float_t> tx.delay[tx_idx],
        <float_t> np.radians(tx.grid[tx_idx])
    )


@cython.cdivision(True)
@cython.boundscheck(False)
@cython.wraparound(False)
cdef RxChannel[float_t] cp_RxChannel(rx,
                                     rx_idx):
    """
    cp_RxChannel(tx, tx_idx)

    Creat RxChannel object in Cython

    :param Receiver rx:
        Radar receiver
    :param int rx_idx:
        Rx channel index

    :return: C++ object of a receiver channel
    :rtype: RxChannel
    """
    cdef vector[float_t] az_ang_vect, az_ptn_vect
    cdef float_t[:] az_ang_mem, az_ptn_mem
    cdef vector[float_t] el_ang_vect, el_ptn_vect
    cdef float_t[:] el_ang_mem, el_ptn_mem

    # azimuth pattern
    az_ang_mem = np.radians(rx.az_angles[rx_idx]).astype(np_float)
    az_ptn_mem = rx.az_patterns[rx_idx].astype(np_float)

    Mem_Copy(&az_ang_mem[0], <int_t>(len(rx.az_angles[rx_idx])), az_ang_vect)
    Mem_Copy(&az_ptn_mem[0], <int_t>(len(rx.az_patterns[rx_idx])), az_ptn_vect)

    # elevation pattern
    el_ang_mem = np.radians(np.flip(90-rx.el_angles[rx_idx])).astype(np_float)
    el_ptn_mem = np.flip(rx.el_patterns[rx_idx]).astype(np_float)

    Mem_Copy(&el_ang_mem[0], <int_t>(len(rx.el_angles[rx_idx])), el_ang_vect)
    Mem_Copy(&el_ptn_mem[0], <int_t>(len(rx.el_patterns[rx_idx])), el_ptn_vect)

    return RxChannel[float_t](
        Vec3[float_t](
            <float_t> rx.locations[rx_idx, 0],
            <float_t> rx.locations[rx_idx, 1],
            <float_t> rx.locations[rx_idx, 2]
        ),
        Vec3[float_t](0, 0, 1),
        az_ang_vect,
        az_ptn_vect,
        el_ang_vect,
        el_ptn_vect,
        <float_t> rx.antenna_gains[rx_idx]
    )


@cython.cdivision(True)
@cython.boundscheck(False)
@cython.wraparound(False)
cdef Target[float_t] cp_Target(radar,
                               target,
                               shape):
    """
    cp_Target(tx, tx_idx)

    Creat Target object in Cython

    :param Radar radar:
        Radar object
    :param dict target:
        Target properties
    :param tuple shape:
        Shape of the time matrix

    :return: C++ object of a target
    :rtype: Target
    """
    timestamp = radar.timestamp.astype(np_float)
    cdef float_t[:, :] points_mem
    cdef int_t[:, :] cells_mem
    cdef float_t[:] origin

    # vector of location, speed, rotation, rotation rate
    cdef vector[Vec3[float_t]] loc_vect
    cdef vector[Vec3[float_t]] spd_vect
    cdef vector[Vec3[float_t]] rot_vect
    cdef vector[Vec3[float_t]] rrt_vect

    cdef float_t[:, :, :] loc_x, loc_y, loc_z
    cdef float_t[:, :, :] spd_x, spd_y, spd_z
    cdef float_t[:, :, :] rot_x, rot_y, rot_z
    cdef float_t[:, :, :] rrt_x, rrt_y, rrt_z

    cdef cpp_complex[float_t] ep, mu

    cdef int_t ch_idx, ps_idx, sp_idx

    t_mesh = meshio.read(target['model'])
    points_mem = t_mesh.points.astype(np_float)
    cells_mem = t_mesh.cells[0].data.astype(np.int32)

    origin = np.array(target.get('origin', (0, 0, 0)), dtype=np_float)

    location = np.array(target.get('location', (0, 0, 0)), dtype=object)
    speed = np.array(target.get('speed', (0, 0, 0)), dtype=object)
    rotation = np.array(target.get('rotation', (0, 0, 0)), dtype=object)
    rotation_rate = np.array(target.get( 'rotation_rate', (0, 0, 0)), dtype=object)

    permittivity = target.get('permittivity', 'PEC')
    if permittivity == "PEC":
        ep = cpp_complex[float_t](-1, 0)
        mu = cpp_complex[float_t](1, 0)
    else:
        ep = cpp_complex[float_t](np.real(permittivity), np.imag(permittivity))
        mu = cpp_complex[float_t](1, 0)

    if np.size(location[0]) > 1 or \
        np.size(location[1]) > 1 or \
        np.size(location[2]) > 1 or \
        np.size(speed[0]) > 1 or \
        np.size(speed[1]) > 1 or \
        np.size(speed[2]) > 1 or \
        np.size(rotation[0]) > 1 or \
        np.size(rotation[1]) > 1 or \
        np.size(rotation[2]) > 1 or \
        np.size(rotation_rate[0]) > 1 or \
        np.size(rotation_rate[1]) > 1 or \
        np.size(rotation_rate[2]) > 1:

        if np.size(location[0]) > 1:
            loc_x = location[0].astype(np_float)
        else:
            loc_x = <float_t > location[0] + <float_t > speed[0]*timestamp

        if np.size(location[1]) > 1:
            loc_y = location[1].astype(np_float)
        else:
            loc_y = <float_t > location[1] + <float_t > speed[1]*timestamp

        if np.size(location[2]) > 1:
            loc_z = location[2].astype(np_float)
        else:
            loc_z = <float_t > location[2] + <float_t > speed[2]*timestamp

        if np.size(speed[0]) > 1:
            spd_x = speed[0].astype(np_float)
        else:
            spd_x = np.full(shape, speed[0], dtype=np_float)

        if np.size(speed[1]) > 1:
            spd_y = speed[1].astype(np_float)
        else:
            spd_y = np.full(shape, speed[1], dtype=np_float)

        if np.size(speed[2]) > 1:
            spd_z = speed[2].astype(np_float)
        else:
            spd_z = np.full(shape, speed[2], dtype=np_float)

        if np.size(rotation[0]) > 1:
            rot_x = np.radians(rotation[0]).astype(np_float)
        else:
            rot_x = np.radians(
                rotation[0] + rotation_rate[0]*timestamp).astype(np_float)

        if np.size(rotation[1]) > 1:
            rot_y = np.radians(rotation[1]).astype(np_float)
        else:
            rot_y = np.radians(
                rotation[1] + rotation_rate[1]*timestamp).astype(np_float)

        if np.size(rotation[2]) > 1:
            rot_z = np.radians(rotation[2]).astype(np_float)
        else:
            rot_z = np.radians(
                rotation[2] + rotation_rate[2]*timestamp).astype(np_float)

        if np.size(rotation_rate[0]) > 1:
            rrt_x = np.radians(rotation_rate[0]).astype(np_float)
        else:
            rrt_x = np.full(shape, np.radians(rotation_rate[0]), dtype=np_float)

        if np.size(rotation_rate[1]) > 1:
            rrt_y = np.radians(rotation_rate[1]).astype(np_float)
        else:
            rrt_y = np.full(shape, np.radians(rotation_rate[1]), dtype=np_float)

        if np.size(rotation_rate[2]) > 1:
            rrt_z = np.radians(rotation_rate[2]).astype(np_float)
        else:
            rrt_z = np.full(shape, np.radians(rotation_rate[2]), dtype=np_float)

        for ch_idx in range(0, radar.channel_size*radar.frames):
            for ps_idx in range(0, radar.transmitter.pulses):
                for sp_idx in range(0, radar.samples_per_pulse):
                    loc_vect.push_back(
                        Vec3[float_t](
                            loc_x[ch_idx, ps_idx, sp_idx],
                            loc_y[ch_idx, ps_idx, sp_idx],
                            loc_z[ch_idx, ps_idx, sp_idx]
                        )
                    )
                    spd_vect.push_back(
                        Vec3[float_t](
                            spd_x[ch_idx, ps_idx, sp_idx],
                            spd_y[ch_idx, ps_idx, sp_idx],
                            spd_z[ch_idx, ps_idx, sp_idx]
                        )
                    )
                    rot_vect.push_back(
                        Vec3[float_t](
                            rot_x[ch_idx, ps_idx, sp_idx],
                            rot_y[ch_idx, ps_idx, sp_idx],
                            rot_z[ch_idx, ps_idx, sp_idx]
                        )
                    )
                    rrt_vect.push_back(
                        Vec3[float_t](
                            rrt_x[ch_idx, ps_idx, sp_idx],
                            rrt_y[ch_idx, ps_idx, sp_idx],
                            rrt_z[ch_idx, ps_idx, sp_idx]
                        )
                    )
    else:
        loc_vect.push_back(
            Vec3[float_t](
                <float_t> location[0],
                <float_t> location[1],
                <float_t> location[2]
            )
        )
        spd_vect.push_back(
            Vec3[float_t](
                <float_t> speed[0],
                <float_t> speed[1],
                <float_t> speed[2]
            )
        )
        rot_vect.push_back(
            Vec3[float_t](
                <float_t> np.radians(rotation[0]),
                <float_t> np.radians(rotation[1]),
                <float_t> np.radians(rotation[2])
            )
        )
        rrt_vect.push_back(
            Vec3[float_t](
                <float_t> np.radians(rotation_rate[0]),
                <float_t> np.radians(rotation_rate[1]),
                <float_t> np.radians(rotation_rate[2])
            )
        )

    return Target[float_t](&points_mem[0, 0],
                           &cells_mem[0, 0],
                           <int_t> cells_mem.shape[0],
                           Vec3[float_t](&origin[0]),
                           loc_vect,
                           spd_vect,
                           rot_vect,
                           rrt_vect,
                           ep,
                           mu,
                           <bool> target.get('is_ground', False))

