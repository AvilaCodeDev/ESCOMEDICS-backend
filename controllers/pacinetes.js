const { response } = require("express");
const { select, insert, update, borrar } = require("../db/connection")


const obtenerPacientes = async( req, res = response ) => {
    try {
        const pacientes = await select("*", "v_003_detalles_paciente" );
    
        if( pacientes.rowsAffected == 0 ){
            return res.status(400).json({
                ok: false,
                msg: "Aun no hay pacientes registrados."
            })
        }
    
        return res.status(200).json({
            ok: true,
            pacientes: pacientes.recordset
        })
    } catch (error) {
        console.log( err );
        return res.status(500).json({
            ok: false,
            msg: "Favor de comunicarse con el administrador"
        })
    }
}

const nuevoPaciente = async( req, res = response ) => {
    try {

        const { nombre, ap_paterno, ap_materno, telefono, direccion, curp } = req.body;
        const id =  `ESCOMPAC${nombre.match(/\b(\w)/g).join("")}${ap_paterno[0]}${ap_materno[0]}${curp.substr(curp.length - 3)}`;

        const result = await insert(
            "pacientes", 
            "id_paciente, nombre, ap_paterno, ap_materno, direccion, curp, telefono",
            `'${id}', '${nombre}', '${ap_paterno}', '${ap_materno}', '${direccion}', '${curp}', '${telefono}'`
        );

        if( result?.rowsAffected == 0 ){
            return res.status(500).json({
                ok: false,
                msg: "No se pudo registrar al paciente."
            })
        }

        const paciente = await select("*", "pacientes", `id_paciente = '${id}'` );

        if( paciente?.rowsAffected > 0 ){
            return res.status(200).json({
                ok: true,
                paciente: paciente.recordsets[0],
                msg: "Paciente registrado con exito. "
            })
        }


        
    } catch (error) {
        console.log( error );
        res.status(500).json({
            ok: false,
            msg: "Favor de comunicarse con el administrador"
        })
    }
}

const actualizarPaciente = async( req, res = response) => {
    try {
        const {  id_paciente, nombre, ap_paterno, ap_materno, telefono, direccion, curp } = req.body;
        const paciente = await select("*", "pacientes", `id_paciente = '${ id_paciente }'`);

        if( paciente?.rowsAffected == 0 ){
            return res.status(404).json({
                ok: false,
                msg: "No existe un paciente con ese ID"
            });
        }

        const result = await update(
            'pacientes', 
            `nombre='${ nombre }', ap_paterno='${ap_paterno}', ap_materno='${ap_materno}',telefono='${telefono}', direccion='${direccion}', curp='${curp}'`,
            `id_paciente='${id_paciente}'`);
        
        if( result?.rowsAffected == 0 ){
            return res.status(400).json({
                ok: false,
                msg: "No se pudo modificar el paciente"
            })
        }

        return res.status(200).json({
            ok: true,
            msg: "Paciente modificado exitosamente"
        });
        
    } catch (error) {
        console.log( error );
        res.status(500).json({
            ok: false,
            msg: "Favor de comunicarse con el administrador"
        })
    }
}

const eliminarPaciente = async( req, res = response) => {
    
    try {
        const { id_paciente } = req.body;
        const paciente = await select("*", "pacientes", `id_paciente = '${ id_paciente }'`);
    
        if( paciente?.rowsAffected == 0 ){
            return res.status(404).json({
                ok: false,
                msg: "No existe un paciente con ese ID"
            });
        } 
        
        const result = await borrar('pacientes', `id_paciente='${id_paciente}'`);
        if( result?.rowsAffected == 0){
            return res.status(400).json({
                ok: false,
                msg:"Error al borrar el paciente"
            })
        }

        return res.status(200).json({
            ok: true,
            msg: "Paciente eliminado con exito"
        })
        
    } catch (error) {
        console.log( error );
        res.status(500).json({
            ok: false,
            msg: "Favor de comunicarse con el administrador"
        })
    }
}

module.exports = {
    obtenerPacientes,
    nuevoPaciente,
    actualizarPaciente,
    eliminarPaciente
}