import Api from 'api/api';

export default class LedgerEntryApi {
  
  static getLedgerEntries(page) {
    return Api.backendSend({
      method: 'get',
      url: `/ledger_entries?page=${page}`
    });
  }

}