import GenericFormObject from '../lib/GenericFormObject'
import concat from 'lodash/concat'
import merge from 'lodash/merge'
import ContactPersonFormObject from './ContactPersonFormObject'
import WebsiteFormObject from './WebsiteFormObject'
import LocationFormObject from './LocationFormObject'
import TargetAudienceFiltersOfferFormObject
  from './TargetAudienceFiltersOfferFormObject'

class OfferCreateFormObject extends GenericFormObject {
  static get model() {
    return 'offer'
  }

  static get type() {
    return 'offers'
  }

  static get properties() {
    return [
      'divisions', 'name',  'solution-category', 'code-word',
      'description', 'comment', 'next-steps', 'contact-people',
      'hide-contact-people', 'encounter', 'location', 'area',
      'tags', 'trait-filters', 'language-filters',
      'target-audience-filters-offers', 'openings', 'opening-specification',
      'websites', 'starts-at', 'ends-at'
    ]
  }

  static get submodels() {
    return [
      'divisions', 'next-steps', 'contact-people', 'location',
      'area', 'tags', 'solution-category', 'trait-filters',
      'language-filters', 'target-audience-filters-offers', 'openings',
      'websites'
    ]
  }

  static get submodelConfig() {
    return {
      'divisions': {
        relationship: 'oneToMany',
      },
      'next-steps': {
        relationship: 'oneToMany',
      },
      'contact-people': {
        object: ContactPersonFormObject,
        relationship: 'oneToMany',
      },
      location: {
        object: LocationFormObject,
        relationship: 'oneToOne',
      },
      area: {
        relationship: 'oneToOne',
      },
      tags: {
        relationship: 'oneToMany',
      },
      'trait-filters': {
        relationship: 'oneToMany',
      },
      'language-filters': {
        relationship: 'oneToMany',
      },
      'target-audience-filters-offers': {
        object: TargetAudienceFiltersOfferFormObject,
        relationship: 'oneToMany',
        inverseRelationship: 'belongsTo'
      },
      openings: {
        relationship: 'oneToMany',
      },
      websites: {
        object: WebsiteFormObject,
        relationship: 'oneToMany',
      },
      'solution-category': {
        relationship: 'oneToOne',
      }
    }
  }

  static get formConfig() {
    return {
      divisions: { type: 'filtering-multiselect' },
      name: { type: 'string', addons: ['counter'] },
      description: { type: 'textarea', addons: ['counter'] },
      comment: { type: 'textarea' },
      'next-steps': { type: 'filtering-multiselect', addons: ['counter'] },
      'contact-people': { type: 'creating-multiselect' },
      'hide-contact-people': { type: 'checkbox' },
      'code-word': { type: 'string' },
      encounter: {
        type: 'select', options: [
          'personal', 'hotline', 'email', 'chat', 'online-course', 'forum',
          'portal'
        ]
      },
      location: { type: 'creating-select' },
      area: { type: 'filtering-select' },
      tags: { type: 'filtering-multiselect' },
      'trait-filters': {
        type: 'filtering-multiselect',
        resource: 'filters',
        params: { filters: { type: 'TraitFilter' } }
      },
      'language-filters': {
        type: 'filtering-multiselect',
        resource: 'filters',
        params: { filters: { type: 'LanguageFilter' } }
      },
      'target-audience-filters-offers': {
        type: 'creating-multiselect'
      },
      openings: {
        type: 'filtering-multiselect',
        params: { sort_field: 'sort_value', sort_direction: 'ASC' }
      },
      'opening-specification': { type: 'textarea' },
      'starts-at': { type: 'date' },
      'ends-at': { type: 'date' },
      websites: { type: 'creating-multiselect' },
      'solution-category': { type: 'filtering-select' },
    }
  }

  static get requiredInputs() {
    return [
      'solution-category', 'divisions', 'name',
      'target-audience-filters-offers', 'language-filters', 'description'
    ]
  }

  static get inputMaxLengths() {
    return {
      name: 80,
      description: 450,
      // NOTE: title and description max vals are only recommendations
      'next-steps': 10
    }
  }

  validation() {
    this.applyRequiredInputs()
    this.maybe('next-steps').filled({
      'max_size?': this.constructor.inputMaxLengths['next-steps']
    })
  }
}

class OfferUpdateFormObject extends OfferCreateFormObject {
  // static get properties() {
  //   return concat(
  //     OfferCreateFormObject.properties,
  //     ['old-next-steps']
  //   )
  // }
  //
  // static get formConfig() {
  //   return merge(
  //     OfferCreateFormObject.formConfig, {
  //       'old-next-steps': { type: 'textarea' },
  //     }
  //   )
  // }

  static get readOnlyProperties() {
    return ['aasm-state']
  }
}

export {
  OfferCreateFormObject, OfferUpdateFormObject
}
