ModifierMaster = {
    MODIFIER_TEST = {
        id = 'MODIFIER_TEST',
        duration = 6,
        interval = 1,
        Effects = {{
            model = 'Abilities\\Spells\\Human\\ManaFlare\\ManaFlareTarget.mdl',
            attach_point = 'overhead'
        }},
        Update = function(this)
            local life = GetWidgetLife(this.owner.unit)
            SetWidgetLife(this.owner.unit, life + 10)
            DestroyEffect(AddSpecialEffectTarget('Abilities\\Spells\\Undead\\VampiricAura\\VampiricAuraTarget.mdl', this.owner.unit, 'origin'))
        end,
        debug_string = ''
    },
    MODIFIER_BULLET_TIME = {
        id = 'MODIFIER_BULLET_TIME',
        duration = -1,
        interval = 0.1,
        Effects = {},
        BindAbility = FourCC('A002'),
        LevelValues = {
            EffectRange = {300, 300, 300, 300},
            VelocityDownPercent = {-50, -70, -100, -100}
        },
        Acquire = function(this)
            this.MODIFIER_BULLET_TIME_AffectedBullets = {}
        end,
        Update = function(this)
            for k,prjt in pairs(ProjectilMgr.Projectils) do
                local dis = prjt.position:Distance(GetUnitX(this.owner.unit), GetUnitY(this.owner.unit))
                if this.MODIFIER_BULLET_TIME_AffectedBullets[prjt.uuid] == nil then
                    if dis < this:LV('EffectRange') then
                        local d = prjt.velocity * this:LV('VelocityDownPercent') / 100
                        this.MODIFIER_BULLET_TIME_AffectedBullets[prjt.uuid] = d
                        prjt.velocity = prjt.velocity + d
                    end
                elseif dis > this:LV('EffectRange') then
                    prjt.velocity = prjt.velocity - this.MODIFIER_BULLET_TIME_AffectedBullets[prjt.uuid]
                    this.MODIFIER_BULLET_TIME_AffectedBullets[prjt.uuid] = nil
                end
            end
        end,
        Remove = function(this) this.MODIFIER_BULLET_TIME_AffectedBullets = nil end,
        debug_string = ''
    },
    MODIFIER_TEST2 = {
        id = 'MODIFIER_TEST',
        duration = 7,
        interval = 1,
        Update = function(owner)
            print('Modifer updated! owner is '..GetUnitName(owner.unit))
        end,
        debug_string = ''
    }
}