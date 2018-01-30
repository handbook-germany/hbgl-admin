export default {
  index: {
    assignable: {
      'assignment-actions': [
        'assign-someone-else', 'retrieve-assignment', 'assign-to-system',
        'assign-to-current-user'
      ]
    },

    'offer-translations': {
      fields: [
        'id', 'offer-id', 'locale', 'source', 'name', 'offer_stamp',
        'possibly-outdated', { offer: ['approved-at', 'created-by'] }
      ],
      general_actions: [
        'index', 'export'
      ],
      member_actions: [
        'show', 'edit'
      ]
    },

    'organization-translations': {
      fields: [
        'id', 'organization-id', 'locale', 'source', 'description',
        'possibly-outdated', { organization: ['approved-at'] }
      ],
      general_actions: [
        'index', 'export'
      ],
      member_actions: [
        'show', 'edit'
      ]
    },

    'statistic-charts': {
      fields: [
        'id', 'title', 'ends-at', 'target-model', 'target-field-name'
      ],
      general_actions: [
        'index', 'new'
      ],
      member_actions: [
        'show'
      ]
    },

    offers: {
      fields: [
        'id', 'name', { 'divisions': ['label'] },
        { 'solution-category': ['name'] },
        'aasm-state', 'created-by', 'expires-at'
      ],
      general_actions: [
        'index', 'export', 'new'
      ],
      member_actions: [
        'show', 'edit', 'delete', 'duplicate', 'preview'
      ]
    },

    locations: {
      fields: [
        'id', 'name', 'street', 'addition', 'zip', 'hq', 'visible', 'in-germany',
        { 'federal-state': ['name'] }, { organization: ['name'] },
        { city: ['name'] }
      ],
      general_actions: [
        'index', 'export', 'new'
      ],
      member_actions: [
        'show', 'edit', 'delete'
      ]
    },

    cities: {
      fields: [
        'id', 'name'
      ],
      general_actions: [
        'index', 'export', 'new'
      ],
      member_actions: [
        'show'
      ]
    },

    openings: {
      fields: [
        'name', 'day', 'open', 'close', 'sort-value'
      ],
      general_actions: [
        'index', 'export', 'new'
      ],
      member_actions: [
        'show', 'edit', 'delete'
      ]
    },

    definitions: {
      fields: [
        'key', 'explanation'
      ],
      general_actions: [
        'index', 'export', 'new'
      ],
      member_actions: [
        'show', 'edit', 'delete'
      ]
    },

    tags: {
      fields: [
        'name-de', 'keywords-de', 'explanations-de', 'name-en', 'keywords-en',
        'explanations-en'
      ],
      general_actions: [
        'index', 'export', 'new'
      ],
      member_actions: [
        'show', 'edit', 'delete'
      ]
    },

    'federal-states': {
      fields: [
        'id', 'name'
      ],
      general_actions: [
        'index', 'export',
      ],
      member_actions: [
        'show'
      ]
    },

    'contact-people': {
      fields: [
        'id', 'first-name', 'last-name', { organization: ['name'] },
        { email: ['address'] }, 'area-code-1', 'local-number-1', 'area-code-2',
        'local-number-2'
      ],
      general_actions: [
        'index', 'export', 'new'
      ],
      member_actions: [
        'show', 'edit', 'delete'
      ]
    },

    emails: {
      fields: [
        'id', 'address'
      ],
      general_actions: [
        'index', 'export', 'new'
      ],
      member_actions: [
        'show', 'delete'
      ]
    },

    areas: {
      fields: [
        'id', 'name', 'minlat', 'maxlat', 'minlong', 'maxlong'
      ],
      general_actions: [
        'index', 'export', 'new'
      ],
      member_actions: [
        'show', 'edit', 'delete'
      ]
    },

    'next-steps': {
      fields: [
        'id', 'text-de', 'text-en', 'text-ar', 'text-fr', 'text-pl',
        'text-tr', 'text-ru', 'text-fa'
      ],
      general_actions: [
        'index', 'export', 'new'
      ],
      member_actions: [
        'show', 'edit', 'delete'
      ]
    },

    'solution-categories': {
      association_model_mapping: { parent: 'solution-categories' },
      fields: [
        'id', 'name', { parent: ['name'] }
      ],
      general_actions: [
        'index', 'export', 'new'
      ],
      member_actions: [
        'show', 'edit', 'delete'
      ]
    },

    users: {
      association_model_mapping: {
        'observed-user-teams': 'user-teams'
      },
      fields: [
        'id', 'name', 'email', { 'user-teams': ['name'] },
        { 'observed-user-teams': ['name'] }
      ],
      general_actions: [
        'index'
      ],
      member_actions: [
        'show'
      ]
    },

    'search-locations': {
      fields: [
        'id', 'query', 'latitude', 'longitude', 'created-at', 'updated-at'
      ],
      general_actions: [
        'index', 'export'
      ],
      member_actions: [
        'show'
      ]
    },

    'language-filters': {
      fields: [
        'id', 'name', 'identifier'
      ],
      general_actions: [
        'index', 'export'
      ],
      member_actions: [
        'show'
      ]
    },

    'contacts': {
      fields: [
        'id', 'name', 'email', 'message', 'city', 'url', 'internal_mail',
        'created-at', 'updated-at'
      ],
      general_actions: [
        'index', 'export'
      ],
      member_actions: [
        'show'
      ]
    },

    organizations: {
      association_model_mapping: {
        'current-assignment': 'assignments', receiver: 'users',
        'receiver-team': 'user-teams'
      },
      fields: [
        'id', {
          'current-assignment': {
            receiver: ['name'], 'receiver-team': ['name']
          }
        }, 'offers-count', 'name', 'aasm-state', 'pending-reason',
        'locations-count', { topics: ['name'] }
      ],
      general_actions: [
        'index', 'export', 'new'
      ],
      member_actions: [
        'show', 'edit', 'preview', 'delete'
      ]
    },

    divisions: {
      association_model_mapping: {
        'current-assignment': 'assignments', receiver: 'users',
        'receiver-team': 'user-teams', 'presumed-tags': 'tags',
        'presumed-solution-categories': 'solution-categories'
      },
      fields: [
        'id', {
          'current-assignment': {
            receiver: ['name'], 'receiver-team': ['name']
          }
        }, { organization: ['name'] }, { section: ['identifier'] },
        { city: ['name'] }, { area: ['name'] }, 'size', 'done', 'addition'
      ],
      general_actions: [
        'index', 'export', 'new',
      ],
      member_actions: [
        'show', 'edit', 'delete'
      ]
    },

    'user-teams': {
      association_model_mapping: {
        'observing-users': 'users', parent: 'users', lead: 'users'
      },
      fields: [
        'id', 'name', 'classification', { users: ['name'] },
        { 'observing-users': ['name'] }
      ],
      general_actions: [
        'index', 'new',
      ],
      member_actions: [
        'show', 'edit'
      ]
    },

    assignments: {
      association_model_mapping: {
        creator: 'users', receiver: 'users',
        'receiver-team': 'user-teams', 'creator-team': 'user-teams'
      },
      fields: [
        'id', 'assignable-id', 'assignable-type', {assignable: ['label']},
        {creator: ['name']}, {'creator-team': ['name']}, {receiver: ['name']},
        {'receiver-team': ['name']}, 'message', 'topic', 'created-at',
        'updated-at'
      ],
      inline_fields: [
        'assignable-type', 'assignable-id', 'topic',
        {assignable: ['label']}, {creator: ['name']},  {receiver: ['name']},
        {'receiver-team': ['name']}, 'message', 'updated-at'
      ],
      general_actions: [
        'index'
      ],
      member_actions: [
        'show-assignable', 'edit-assignable'
      ]
    },

    sections: {
      fields: [
        'id', 'name', 'identifier'
      ],
      general_actions: [
        'index'
      ],
      member_actions: [
        'show'
      ],
    },

    websites: {
      fields: [
        'id', 'host', 'url'
      ],
      general_actions: [
        'index'
      ],
      member_actions: [
        'show', 'open_url', 'delete', 'edit'
      ]
    },


    subscriptions: {
      fields: [
        'id', 'email', 'created-at', 'updated-at'
      ],
      general_actions: [
        'index'
      ],
      member_actions: [
        'show', 'delete'
      ]
    },

    'update-requests': {
      fields: [
        'id', 'search-location', 'email', 'created-at', 'updated-at'
      ],
      general_actions: [
        'index'
      ],
      member_actions: [
        'show'
      ],
    },

    'target-audience-filters-offers': {
      association_model_mapping: { 'target-audience-filter': 'filter' },
      fields: ['id', 'target-audience-filter-id', 'offer-id', 'stamp_de'],
      general_actions: [],
      member_actions: []
    },
  },

  OPERATORS: ['=', '!=', '<', '>', '...', 'ILIKE', 'NOT LIKE'],
  SECTIONS: ['family', 'refugees'],
  AFTER_SAVE_ACTIONS: {
    'to_edit': 'Bei dieser Instanz bleiben',
    'to_table': 'Zurück zur Tabelle',
    'to_new': 'Neues Objekt anlegen'
  },

  HISTORY_ENABLED: ['organizations', 'offers']
}
