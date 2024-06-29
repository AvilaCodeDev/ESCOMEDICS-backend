const { Router } = require('express');
const { check } = require('express-validator');
const { validarCampos } = require('../middlewares/validar-campos');
const { validarJWT } = require('../middlewares/validar-jwt');
const { obtieneDisponibilidadCitas, obtieneCitasPaciente, agregaNuevaCita, obtieneHistorialCitas } = require('../controllers/citas');

const router = Router();


router.post(
    '/disponibilidadCitas',
    validarJWT,
    obtieneDisponibilidadCitas
);

router.post(
    '/obtieneCitasPaciente',
    // validarJWT,
    obtieneCitasPaciente
);
router.post(
    '/agregaNuevaCita',
    // validarJWT,
    agregaNuevaCita
);

router.get(
    '/obtieneHistorialCitas',
    obtieneHistorialCitas
)

module.exports = router;