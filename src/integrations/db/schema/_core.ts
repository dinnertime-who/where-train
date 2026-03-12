import { createId } from "@paralleldrive/cuid2";
import { text, timestamp } from "drizzle-orm/pg-core";

export const cuidPrimaryKey = () => {
  return text("id")
    .$defaultFn(() => createId())
    .primaryKey();
};

export const createdAt = () => timestamp("created_at").defaultNow().notNull();

export const updatedAt = () =>
  timestamp("updated_at")
    .defaultNow()
    .$onUpdate(() => /* @__PURE__ */ new Date())
    .notNull();

export const deletedAt = () => timestamp("deleted_at");
