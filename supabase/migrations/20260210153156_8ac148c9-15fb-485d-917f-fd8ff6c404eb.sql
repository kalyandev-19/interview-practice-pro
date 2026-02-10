
-- Create interview_sessions table
CREATE TABLE public.interview_sessions (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL,
  job_role TEXT NOT NULL,
  difficulty TEXT NOT NULL DEFAULT 'medium',
  status TEXT NOT NULL DEFAULT 'in_progress',
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  completed_at TIMESTAMP WITH TIME ZONE
);

ALTER TABLE public.interview_sessions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own sessions" ON public.interview_sessions FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can create own sessions" ON public.interview_sessions FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own sessions" ON public.interview_sessions FOR UPDATE USING (auth.uid() = user_id);

-- Create interview_questions table
CREATE TABLE public.interview_questions (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  session_id UUID NOT NULL REFERENCES public.interview_sessions(id) ON DELETE CASCADE,
  question_text TEXT NOT NULL,
  answer_transcript TEXT,
  audio_url TEXT,
  question_order INTEGER NOT NULL DEFAULT 1,
  clarity_score INTEGER,
  relevance_score INTEGER,
  improvement_tips TEXT,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

ALTER TABLE public.interview_questions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own questions" ON public.interview_questions FOR SELECT 
  USING (EXISTS (SELECT 1 FROM public.interview_sessions WHERE id = interview_questions.session_id AND user_id = auth.uid()));
CREATE POLICY "Users can insert own questions" ON public.interview_questions FOR INSERT 
  WITH CHECK (EXISTS (SELECT 1 FROM public.interview_sessions WHERE id = interview_questions.session_id AND user_id = auth.uid()));
CREATE POLICY "Users can update own questions" ON public.interview_questions FOR UPDATE 
  USING (EXISTS (SELECT 1 FROM public.interview_sessions WHERE id = interview_questions.session_id AND user_id = auth.uid()));
