'use strict'

/** @module route */

const express = require('express')
const passport = require('passport')
const database = require('./database_init')
const bodyParser = require('body-parser')
const session = require('express-session')
require('dotenv').config({ path: '../database.env' })
const app = express()

const swaggerUi = require('swagger-ui-express')
const swaggerConfig = require('./swaggerdoc.json')

app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerConfig))

passport.serializeUser((user, done) => {
  done(null, user.id)
})

passport.deserializeUser((id, done) => {
  done(null, { id: id })
})

app.use(bodyParser.json())
app.use(session({ secret: 'SECRET', resave: false, saveUninitialized: false }))
app.use(passport.initialize())
app.use(passport.session())

app.set('json spaces', 2)

const PORT = 8080
const HOST = '0.0.0.0'

/**
 * Set the header protocol to authorize Web connection
 * @memberof route
 */
app.use(function (req, res, next) {
  // Allow access request from any computers
  res.header('Access-Control-Allow-Origin', '*')
  res.header(
    'Access-Control-Allow-Headers',
    'Origin, X-Requested-With, Content-Type, Accept, Authorization'
  )
  res.header('Access-Control-Allow-Methods', 'POST, GET, PUT, DELETE,PATCH')
  res.header('Access-Control-Allow-Credentials', true)
  if ('OPTIONS' == req.method) {
    res.sendStatus(200)
  } else {
    next()
  }
})

/**
 * Welcoming path
 * @memberof route
 * @function
 * @name welcomingPath
 */
app.get('/', (req, res) => {
  res.send('Hello World')
})

/**
 * @swagger
 * /about.json:
 *  get:
 *    tags: [About]
 *    summary: Get info about server
 *    responses:
 *      200:
 *        description: OK
 *      500:
 *        description: Internal server error
 */
app.get('/about.json', async (req, res) => {
  try {
    const about = {}
    about.client = { host: req.ip }
    about.server = {
      current_time: Date.now(),
      services: []
    }
    res.header('Content-Type', 'application/json')
    res.type('json').send(JSON.stringify(about, null, 2) + '\n')
  } catch (err) {
    console.log(err)
    res.status(500).send(err)
  }
})

/**
 * @swagger
 * components:
 *   schemas:
 *     Action:
 *       type: object
 *       properties:
 *         id:
 *           type: integer
 *         name:
 *           type: string
 *         description:
 *           type: string
 *         createdAt:
 *           type: string
 *         updatedAt:
 *           type: string
 *     Reaction:
 *       type: object
 *       properties:
 *         id:
 *           type: integer
 *         name:
 *           type: string
 *         description:
 *           type: string
 *         createdAt:
 *           type: string
 *         updatedAt:
 *           type: string
 *     Parameter:
 *       type: object
 *       properties:
 *         id:
 *           type: integer
 *         name:
 *           type: string
 *         isRequired:
 *           type: boolean
 *         description:
 *           type: string
 *         createdAt:
 *           type: string
 *         updatedAt:
 *           type: string
 *         Action:
 *           type: object
 *           properties:
 *             id:
 *               type: integer
 *             name:
 *               type: string
 *         Reaction:
 *           type: object
 *           properties:
 *             id:
 *               type: integer
 *             name:
 *               type: string
 *     Service:
 *       type: object
 *       properties:
 *         id:
 *           type: integer
 *         name:
 *           type: string
 *         description:
 *           type: string
 *         createdAt:
 *           type: string
 *         updatedAt:
 *           type: string
 *         Actions:
 *           type: array
 *           items:
 *              $ref: '#/components/schemas/Action'
 *         Reactions:
 *           type: array
 *           items:
 *              $ref: '#/components/schemas/Reaction'
 *         Parameters:
 *           type: array
 *           items:
 *             $ref: '#/components/schemas/Parameter'
 */

/**
 * Start the node.js server at PORT and HOST variable
 */
app.listen(PORT, HOST, async () => {
  console.log(`Server is starting...`)
  await generateAllServices(database)
  await initAdministratorAccount()
  console.log(`Server running http://${HOST}:${PORT}`)
  console.log(`Api documentation available on http://${HOST}:${PORT}/api-docs`)
})

/**
 * A basic function to demonstrate the test framework.
 * @param {*} number A basic number
 * @returns The passed number
 */
function test_example (number) {
  return number
}

module.exports = { test_example, app }
