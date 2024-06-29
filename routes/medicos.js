const { Router } = require('express');
const { check } = require('express-validator');
const { validarCampos } = require('../middlewares/validar-campos');
const { validarJWT } = require('../middlewares/validar-jwt');
const { consultaUsuarios, registraUsuario } = require('../controllers/usuarios');
const { obtieneEspecialidades, obtieneConsultorios, obtieneMedicosEspecialidad } = require('../controllers/medicos');

const router = Router();


router.get(
    '/obtieneEspecialidades',
    validarJWT,
    obtieneEspecialidades
);

router.get(
    '/obtieneConsultorios',
    validarJWT,
    obtieneConsultorios
)

router.post(
    '/obtieneMedicosEspecialidad',
    validarJWT,
    obtieneMedicosEspecialidad
)

module.exports = router;