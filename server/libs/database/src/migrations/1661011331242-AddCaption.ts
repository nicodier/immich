import { MigrationInterface, QueryRunner } from "typeorm";

export class AddCaption1661011331242 implements MigrationInterface {
    name = 'AddCaption1661011331242'

    public async up(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`ALTER TABLE "exif" ADD "description" text DEFAULT ''`);
        await queryRunner.query(`ALTER TABLE "exif" ADD "fps" double precision`);
        // await queryRunner.query(`ALTER TABLE "exif" ALTER COLUMN "exifTextSearchableColumn" SET NOT NULL`);
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        // await queryRunner.query(`ALTER TABLE "exif" ALTER COLUMN "exifTextSearchableColumn" DROP NOT NULL`);
        await queryRunner.query(`ALTER TABLE "exif" DROP COLUMN "fps"`);
        await queryRunner.query(`ALTER TABLE "exif" DROP COLUMN "description"`);
    }

}
