const { Router } = require("express");
const { obtenerPacientes, nuevoPaciente, actualizarPaciente, eliminarPaciente } = require("../controllers/pacinetes");
const { validarJWT } = require("../middlewares/validar-jwt");

const router = Router();

router.use( validarJWT );

router.get(
    '/',
    obtenerPacientes
);

router.put(
    '/:id',
    actualizarPaciente
)

router.post(
    '/registrarPaciente',
    nuevoPaciente
)

router.delete('/:id', eliminarPaciente );

module.exports = router;