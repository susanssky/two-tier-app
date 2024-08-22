import express from 'express'
import { requestStress } from '../controllers/stress'

const router = express.Router()

router.route('/').post(requestStress)

export default router
