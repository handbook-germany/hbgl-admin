import GenericFormObject from '../lib/GenericFormObject'
import WebsiteFormObject from './WebsiteFormObject'
import merge from 'lodash/merge'
import concat from 'lodash/concat'

class DivisionUpdateFormObject extends GenericFormObject {
  static get model() {
    return 'division'
  }

  static get type() {
    return 'divisions'
  }

  static get properties() {
    return [
      'addition', 'organization', 'city', 'area', 'websites',
      'presumed-tags', 'presumed-solution-categories', 'comment',
      'size'
    ]
  }

  static get submodels() {
    return [
      'organization', 'websites', 'city', 'area',
      'presumed-tags', 'presumed-solution-categories'
    ]
  }

  static get submodelConfig() {
    return {
      websites: { relationship: 'oneToMany', object: WebsiteFormObject },
      city: { relationship: 'oneToOne' },
      area: { relationship: 'oneToOne' },
      organization: { relationship: 'oneToOne' },
      'presumed-tags': { relationship: 'oneToMany' },
      'presumed-solution-categories': { relationship: 'oneToMany' },
    }
  }

  static get formConfig() {
    return {
      addition: { type: 'string' },
      organization: { type: 'filtering-select' },
      city: { type: 'filtering-select' },
      area: { type: 'filtering-select' },
      websites: { type: 'creating-multiselect' },
      'presumed-tags': {
        type: 'filtering-multiselect', resource: 'tags'
      },
      'presumed-solution-categories': {
        type: 'filtering-multiselect', resource: 'solution-categories'
      },
      comment: { type: 'textarea' },
      size: { type: 'select', options: ['small', 'medium', 'large'] },
    }
  }

  static get readOnlyProperties() {
    return ['section-identifier']
  }

  static get requiredInputs() {
    return []
  }

  validation() {
    for (let requiredInput of this.constructor.requiredInputs) {
      this.required(requiredInput).filled()
    }
  }
}

class DivisionCreateFormObject extends DivisionUpdateFormObject {
  // static get properties() {
  //   return concat(['section'], DivisionUpdateFormObject.properties)
  // }
  //
  // static get submodels() {
  //   return concat(['section'], DivisionUpdateFormObject.submodels)
  // }
  //
  // static get submodelConfig() {
  //   return merge(
  //     { section: { relationship: 'oneToOne' } },
  //     DivisionUpdateFormObject.submodelConfig
  //   )
  // }
  //
  // static get formConfig() {
  //   return merge(
  //     { section: { type: 'filtering-select' } },
  //     DivisionUpdateFormObject.formConfig
  //   )
  // }
  //
  // static get requiredInputs() {
  //   return ['section']
  // }
  //
  static get readOnlyProperties() {
    return []
  }
}

export {
  DivisionCreateFormObject, DivisionUpdateFormObject
}
