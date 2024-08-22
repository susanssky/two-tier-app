import express from 'express'
import { getCurrentInstance } from '../controllers/aws'

const router = express.Router()

router.route('/').get(getCurrentInstance)

export default router
