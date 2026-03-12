import { pgTable, text } from "drizzle-orm/pg-core";
import { cuidPrimaryKey, createdAt, updatedAt } from "./_core";

export const demo = pgTable("demo", {
  id: cuidPrimaryKey(),
  name: text("name").notNull(),
  createdAt: createdAt(),
  updatedAt: updatedAt(),
});
