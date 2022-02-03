"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const moment_1 = __importDefault(require("moment"));
const client_1 = require("@prisma/client");
const prisma = new client_1.PrismaClient();
function me(req, res, next) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const user = yield prisma.user.findUnique({
                where: {
                    id: req.body.user_id,
                },
            });
            req.body.dbUser = user;
            next();
        }
        catch (e) {
            res.status(500).send({ error: e.message || "Error fetching user" });
        }
    });
}
function updateAccountDetails(req, res, next) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            // update timezone if it has changed
            let tzOffset = req.query.tzOffset;
            tzOffset = parseInt(tzOffset);
            if (tzOffset !== req.body.dbUser.timezone_offset) {
                let user = yield prisma.user.update({
                    where: { id: req.body.dbUser.id },
                    data: {
                        timezone_offset: tzOffset,
                    },
                });
                req.body.dbUser = user;
            }
            // update user streak if neccesary
            let last_login = moment_1.default.utc(req.body.dbUser.last_login);
            let timezone_offset = req.body.dbUser.timezone_offset;
            let local_last_login = last_login.subtract(timezone_offset, "minutes");
            let local_now = (0, moment_1.default)().subtract(timezone_offset, "minutes");
            const last_day = local_last_login.dayOfYear();
            const now_day = local_now.dayOfYear();
            const diff = now_day - last_day;
            if (diff !== 0) {
                let newStreak = 0;
                if (diff === 1 || (now_day === 1 && diff === -364)) {
                    newStreak = req.body.dbUser.streak + 1;
                }
                else {
                    newStreak = 1;
                }
            }
            next();
        }
        catch (err) {
            console.log(err.message);
            res.status(500).send({ error: err.message || "Error fetching user" });
        }
    });
}
function create(req, res) {
    return __awaiter(this, void 0, void 0, function* () {
        if (!req.body) {
            res.status(400).send({
                message: "Content can not be empty!",
            });
            return;
        }
        try {
            const user = yield prisma.user.create({
                data: {
                    email: req.body.email,
                    password: req.body.password,
                },
            });
            res.status(200).send(user);
        }
        catch (e) {
            res.status(500).send({ error: e.message || "Error creating user" });
        }
    });
}
module.exports = {
    me,
    updateAccountDetails,
    create,
};
