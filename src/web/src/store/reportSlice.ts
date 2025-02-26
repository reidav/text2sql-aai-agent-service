import { createSlice, PayloadAction } from "@reduxjs/toolkit";
import { IReport, IReportCollection } from ".";

const initialState: IReportCollection = {
  current: 0,
  reports: [],
  currentReport: undefined
};

const reportSlice = createSlice({
  name: "report",
  initialState,
  reducers: {
    addReport: (state, action: PayloadAction<IReport>) => {
      state.reports.push(action.payload);
      state.current = state.reports.length - 1;
      state.currentReport = action.payload;
    },
    clearReports: () => {
      return initialState;
    },
    setCurrentReport: (state, action: PayloadAction<number>) => {
      if (action.payload < 0 || action.payload >= state.reports.length) {
        return;
      }
      state.current = action.payload;
      state.currentReport = state.reports[action.payload];
    },
    // addToCurrentReport: (state, action: PayloadAction<string>) => {
    //   state.reports[state.current] += action.payload;
    //   state.currentReport = state.reports[state.current];
    // },
  },
});

export const { addReport, clearReports, setCurrentReport } =
  reportSlice.actions;
export default reportSlice.reducer;
