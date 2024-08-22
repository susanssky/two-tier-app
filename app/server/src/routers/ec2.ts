import express from 'express'
import {
  getEc2fromDb,
  callSdkToGetEc2Again,
  updateEc2Bookmarked,
} from '../controllers/ec2'

const router = express.Router()

router
  .route('/')
  .get(getEc2fromDb)
  .post(callSdkToGetEc2Again)
  .patch(updateEc2Bookmarked)

export default router
