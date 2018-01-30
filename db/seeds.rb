Offer.clear_index!

user = User.create! email: 'user@user.com', password: 'password',
                    role: 'researcher', name: 'Regina Research'
admin = User.create! email: 'admin@admin.com', password: 'password',
                     role: 'super', name: 'Agathe Admin'

team = UserTeam.create! name: 'The Experts'
team.users << user
team.users << admin

family = Section.create name: 'Family', identifier: 'family'
refugees = Section.create name: 'Refugees', identifier: 'refugees'
LanguageFilter.create name: 'Deutsch', identifier: 'deu'
LanguageFilter.create name: 'Englisch', identifier: 'eng'
LanguageFilter.create name: 'Türkisch', identifier: 'tur'
TargetAudienceFilter.create name: 'Kinder', identifier: 'family_children'
TargetAudienceFilter.create name: 'Eltern', identifier: 'family_parents'
TargetAudienceFilter.create name: 'Familie', identifier: 'family_nuclear_family'
TargetAudienceFilter.create name: 'Bekannte', identifier: 'family_relatives'

LogicVersion.create(version: 1, name: 'Altlasten')
LogicVersion.create(version: 2, name: 'Split Revolution')
LogicVersion.create(version: 3, name: 'TKKG')

schland = Area.create name: 'Deutschland', minlat: 47.270111, maxlat: 55.058347,
                      minlong: 5.866342, maxlong: 15.041896
berlin = Area.create name: 'Berlin', minlat: 52.339630, maxlat: 52.675454,
                     minlong: 13.089155, maxlong: 13.761118
Area.create name: 'Brandenburg & Berlin', minlat: 51.359059, maxlat: 53.558980,
            minlong: 11.268746, maxlong: 14.765826

FederalState.create name: 'Berlin'
FederalState.create name: 'Brandenburg'
FederalState.create name: 'Baden-Württemberg'
FederalState.create name: 'Bayern'
FederalState.create name: 'Bremen'
FederalState.create name: 'Hamburg'
FederalState.create name: 'Hessen'
FederalState.create name: 'Mecklenburg-Vorpommern'
FederalState.create name: 'Niedersachsen'
FederalState.create name: 'Nordrhein-Westfalen'
FederalState.create name: 'Saarland'
FederalState.create name: 'Sachsen'
FederalState.create name: 'Sachsen-Anhalt'
FederalState.create name: 'Schleswig-Holstein'
FederalState.create name: 'Thüringen'
FederalState.create name: 'Rheinland-Pfalz'
FederalState.create name: 'Mallorca' # Don't do this in production :)

SearchLocation.create query: 'Berlin', latitude: 52.520007,
                                       longitude: 13.404954,
                                       geoloc: '52.520007,13.404954'

FactoryGirl.create :tag, :with_dummy_translations,
                         name_de: 'Familie'
FactoryGirl.create :tag, :with_dummy_translations,
                           name_de: 'Asyl und Recht'
FactoryGirl.create :tag, :with_dummy_translations,
                            name_de: 'Gesundheit'
FactoryGirl.create :tag, :with_dummy_translations,
                           name_de: 'Lernen und Arbeiten'
FactoryGirl.create :tag, :with_dummy_translations,
                          name_de: 'Sorgen im Alltag'
FactoryGirl.create :tag, :with_dummy_translations,
                          name_de: 'Leben in Deutschland'
FactoryGirl.create :tag, :with_dummy_translations,
                              name_de: 'Gewalt'
FactoryGirl.create :tag, :with_dummy_translations,
                            name_de: 'Notfall'

20.times do
    FactoryGirl.create :tag, :with_dummy_translations
end

tags = Tag.all
FactoryGirl.create :offer, :approved, :with_dummy_translations,
                   approved_by: user, name: 'Lokales Angebot',
                   encounter: 'personal', tags: [tags.sample]
FactoryGirl.create :offer, :approved, :with_dummy_translations,
                   approved_by: user, name: 'Lokale Hotline',
                   encounter: 'hotline', area: berlin, tags: [tags.sample]
FactoryGirl.create :offer, :approved, :with_dummy_translations,
                   approved_by: user, name: 'Bundesweiter Chat',
                   encounter: 'chat', area: schland, tags: [tags.sample]
FactoryGirl.create :offer, :approved, :with_dummy_translations,
                   approved_by: user, name: 'Bundesweite Hotline',
                   encounter: 'hotline', area: schland, tags: [tags.sample]
