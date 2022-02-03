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
Object.defineProperty(exports, "__esModule", { value: true });
const client_1 = require("@prisma/client");
const prisma = new client_1.PrismaClient();
function create(req, res) {
    return __awaiter(this, void 0, void 0, function* () {
        if (!req.body.name) {
            res.status(400).send({
                message: "Goal cannot be empty!",
            });
            return;
        }
        try {
            const goal = yield prisma.goal.create({
                data: {
                    name: req.body.name,
                    content: req.body.content,
                    period: req.body.period,
                    status: req.body.status,
                    user_id: req.body.user_id,
                },
            });
            res.status(200).send(goal);
        }
        catch (e) {
            res.status(500).send({ error: e.message || "Error creating goal." });
        }
    });
}
function update(req, res) {
    return __awaiter(this, void 0, void 0, function* () {
        if (!req.body.content) {
            res.status(400).send({
                message: "Content can not be empty!",
            });
            return;
        }
        try {
            const goal = yield prisma.goal.update({
                where: {
                    id: req.body.id,
                },
                data: {
                    name: req.body.name,
                    content: req.body.content,
                    period: req.body.period,
                    status: req.body.status,
                },
            });
            res.status(200).send(goal);
        }
        catch (e) {
            res.status(500).send({ error: e.message || "Error creating goal." });
        }
    });
}
function findAll(req, res) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const archivedStr = req.query.archived;
            const archived = archivedStr === "true" ? true : false;
            const goals = yield prisma.goal.findMany({
                where: {
                    user_id: req.body.user_id,
                    archived: archived,
                },
                orderBy: {
                    created_at: "asc",
                },
            });
            res.status(200).send(goals);
        }
        catch (e) {
            console.log(e);
            res
                .status(500)
                .send({ error: e.message || "Error fetching goals for user." });
        }
    });
}
function destroy(req, res) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            const _id = req.params.id;
            const id = parseInt(_id);
            const goal = yield prisma.goal.delete({
                where: {
                    id,
                },
            });
            res.status(200).send({ id: goal.id });
        }
        catch (e) {
            res.status(500).send({ error: e.message || "Error destroying goal." });
        }
    });
}
module.exports = {
    findAll,
    create,
    update,
    destroy,
};
