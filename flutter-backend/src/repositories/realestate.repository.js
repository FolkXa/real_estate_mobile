const pool = require('../config/db.config');

class RealEstateRepository {
    async getAll() {
        const result = await pool.query('SELECT * FROM real_estate WHERE active = TRUE');
        return result.rows;
    }

    async getById(id) {
        const result = await pool.query('SELECT * FROM real_estate WHERE real_estate_id = $1 AND active = TRUE', [id]);
        return result.rows[0];
    }

    async create(data) {
        const result = await pool.query(
            `INSERT INTO real_estate (user_id, type_realestate, type_sell, address, tambon, amphur, province, details, view, premium_promote, active) 
             VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, TRUE) RETURNING *`,
            [
                data.user_id, data.type_realestate, data.type_sell, data.address, 
                data.tambon, data.amphur, data.province, data.details, 
                data.view || 0, data.premium_promote || false
            ]
        );
        return result.rows[0];
    }

    async update(id, data) {
        const result = await pool.query(
            `UPDATE real_estate 
             SET type_realestate = $1, type_sell = $2, address = $3, tambon = $4, amphur = $5, 
                 province = $6, details = $7, view = $8, premium_promote = $9, updated_at = NOW()
             WHERE real_estate_id = $10 RETURNING *`,
            [
                data.type_realestate, data.type_sell, data.address, data.tambon, data.amphur,
                data.province, data.details, data.view, data.premium_promote, id
            ]
        );
        return result.rows[0];
    }

    async softDelete(id) {
        const result = await pool.query('UPDATE real_estate SET active = FALSE WHERE real_estate_id = $1 RETURNING *', [id]);
        return result.rows[0];
    }
    async reactivateRealEstate(realEstateId) {
        const result = await pool.query(
            'UPDATE real_estate SET active = TRUE, updated_at = NOW() WHERE real_estate_id = $1 RETURNING *',
            [realEstateId]
        );
        return result.rows[0];
    }
    async activatePremiumPromotion(id, promotionDuration) {
        const { promote_at, promote_end } = promotionDuration;
        const promoteAt = new Date(promote_at).toISOString();
        const promoteEnd = new Date(promote_end).toISOString();
    
        const result = await pool.query(
            `UPDATE real_estate
             SET premium_promote = TRUE, promote_at = $1, promote_end = $2, updated_at = NOW()
             WHERE real_estate_id = $3 RETURNING *`,
            [promoteAt, promoteEnd, id]
        );
        return result.rows[0];
    }
    
    async deactivatePremiumPromotion(id) {
        const result = await pool.query(
            `UPDATE real_estate
             SET premium_promote = FALSE, promote_at = NULL, promote_end = NULL, updated_at = NOW()
             WHERE real_estate_id = $1 RETURNING *`,
            [id]
        );
        return result.rows[0];
    }

    async incrementView(id) {
        const result = await pool.query(
            `UPDATE real_estate
            SET view = view + 1, updated_at = NOW()
            WHERE real_estate_id = $1 RETURNING *`,
            [id]
        );
        return result.rows[0];
    }

}

module.exports = new RealEstateRepository();
