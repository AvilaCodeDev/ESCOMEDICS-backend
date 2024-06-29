const { response } = require("express");
const { select, callTableFunction, callStoreProcedure } = require("../db/connection");


const consultaUsuarios = async( req, res = response ) => {
    try {
        const result = await select("*","v_001_consultar_usuarios");
        const dataUsuarios = result.recordset;

        return res.json({
            ok: true,
            dataUsuarios
        });
    } catch (error) {
        console.log( error );
        return res.status(400).json( error );
    }
}

const getDetallesUsuario = async( req, res = response ) => {
    try {
        const { id_usuario, id_rol } = req.body;
        const result = await callStoreProcedure('sp_010_obtiene_datos_usuario', [id_usuario, id_rol]);
        const dataUsuario = result.recordset;

        console.log( dataUsuario )

        return res.json({
            ok: true,
            dataUsuarios
        });
    } catch (error) {
        console.log( error );
        return res.status(400).json( error );
    }
}

const registraUsuario = async( req, res = response ) => {
    try {
        const {
            nombre,
            ap_paterno,
            ap_materno,
            sexo,
            curp,
            telefono,
            direccion,
            correo,
            id_rol,
            tipo_paciente,
            id_horario,
            cedula,
            id_especialidad,
            id_consultorio,
            estatus
        } = req.body;

        const password = `${nombre.substring(0,3).toLowerCase()}${curp.substring( curp.length - 4 )}`

        const params = [
            nombre,
            ap_paterno,
            ap_materno,
            sexo,
            curp,
            telefono,
            direccion,
            correo,
            password,
            id_rol,
            tipo_paciente,
            id_horario,
            cedula,
            id_especialidad,
            id_consultorio,
            estatus
        ]
        
        const result = await callStoreProcedure('sp_001_inserta_usuario', params);

        return res.json({
            ok: true,
            msj: "Usuario registrado con exito"
        });
    } catch (error) {
        console.log( error );
        return res.status(400).json( error );    
    }
}

module.exports = {
    consultaUsuarios,
    registraUsuario,
    getDetallesUsuario
}