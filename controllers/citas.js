const response = require('express');
const { select, callTableFunction, callStoreProcedure } = require('../db/connection');
const moment = require('moment');

const agregaNuevaCita = async( req, res = response ) => {
    try {
            const { id_paciente, hora_consulta, fecha_consulta, cedula_prof, id_registra, id_especialidad } = req.body;
            const min_date = moment().add(2, "days").format("L");
            if( new Date( min_date ).getTime() > new Date( fecha_consulta ).getTime() ){
                return res.status(200).json({
                    ok: false,
                    msg: "Las consultas se tienen que agendar con 2 días de anticipación"
                })
            }

            const citas = await select('*',
                'v_006_citas_usuario',
                `id_paciente = ${id_paciente} and id_especialidad = ${id_especialidad} and estatus_consulta = 1`
            );

            if( citas.recordset.length > 0 ){
                const cita_activa = citas.recordset[0]
                return res.json({
                    ok: false,
                    msg: `Ya se cuenta con una cita activa para esta especialidad`,
                    cita_ctiva : cita_activa
                })
            }

            const result = await callStoreProcedure(
                'sp_011_registra_cita',
                [fecha_consulta, hora_consulta, cedula_prof, id_paciente, id_registra]
            );
        return res.status(200).json({
            ok: true,
            msg: "La consulta se ha agendado exitosamente"
            
        })
    } catch (error) {
        console.log( error );
        return res.status(400).json( error );    
    }
}

const obtieneDisponibilidadCitas = async( req, res = response) => {
    try {
        const { cedula_prof } = req.body;
        const result = await callTableFunction('fn_003_obtiene_disponibilidad_consultas', [cedula_prof]);
        const {json_disponibilidad} = result.recordset[0];
        const citasDisponibles = JSON.parse(json_disponibilidad)


        return res.status(200).json({
            ok: true,
            citasDisponibles
            
        })
    } catch (error) {
        console.log( error );
        return res.status(400).json( error );    
    }
}

const obtieneCitasPaciente = async( req, res = response ) => {
    try {
        const { id_paciente, estatus } = req.body;
        const result = await callTableFunction('fn_004_obtiene_citas_agendadas_paciente', [id_paciente,estatus])

        if( result.recordset.length < 0){
            return res.status(200).json({
                ok: true,
                msg: "Agendar Cita"
            })
        }

        const { consultas } = JSON.parse(result.recordset[0].json_citas);

        return res.status(200).json({
            ok: true,
            consultas
        })
    } catch (error) {
        console.log( error );
        return res.status(400).json( error );    
    }   
}

const obtieneHistorialCitas = async( req, res = response ) => {
    try {
        const result = await select('*',
            'v_006_citas_usuario'
        );
        const citas = result.recordset;
        if( citas.length < 0){
            return res.json({
                ok: true,
                msg: "No hay citas agendadas"
            })
        }
        return res.status(200).json({
            ok: true,
            citas
        })
    } catch (error) {
        console.log( error );
        return res.status(400).json( error );    
    }   
}


module.exports = {
    obtieneDisponibilidadCitas,
    obtieneCitasPaciente,
    agregaNuevaCita,
    obtieneHistorialCitas
}