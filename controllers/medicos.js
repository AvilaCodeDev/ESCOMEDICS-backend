const response = require('express');
const { select } = require('../db/connection');

const obtieneEspecialidades = async( req, res = response ) => {
    try {
        const result = await select("id_especialidad as 'key', nombre_especialidad as 'label'", "Especialidades","");
        const recordset = result.recordset;

        if( recordset.length == 0 ){
            return res.status(200).json({
                ok: true,
                msg: "No hay especialidades"
            })
        }
        
        return res.status(200).json({
            ok: true,
            especialidades: recordset
        });
    } catch (error) {
        console.log( error );
        return res.status(400).json({
            ok : false,
            msg : "Favor de contactar al administrados"
        });
    }
}
const obtieneConsultorios = async( req, res = response ) => {
    try {
        const result = await select("id_consultorio as 'key', id_consultorio as 'label'", "Consultorios","");
        const recordset = result.recordset;

        if( recordset.length == 0 ){
            return res.status(200).json({
                ok: true,
                msg: "No hay consultorios"
            })
        }
        
        return res.status(200).json({
            ok: true,
            consultorios: recordset
        });
    } catch (error) {
        console.log( error );
        return res.status(400).json({
            ok : false,
            msg : "Favor de contactar al administrados"
        });
    }
}

const obtieneMedicosEspecialidad = async( req, res = response ) => {
    try {
        const { id_especialidad } = req.body;
        const result = await select(
            "cedula_prof as 'key', (nombre+' '+ap_paterno+' '+ap_materno) as 'label'",
            "v_002_detalles_medico",
            `id_especialidad = ${id_especialidad}`
        );
        const medicosEspecialidad = result.recordset;


        return res.status(200).json({
            ok: true,
            medicosEspecialidad
        });
        
    } catch (error) {
        console.log( error );
        return res.status(400).json({
            ok : false,
            msg : "Favor de contactar al administrados"
        });
    }
}

module.exports = {
    obtieneEspecialidades,
    obtieneConsultorios,
    obtieneMedicosEspecialidad
}